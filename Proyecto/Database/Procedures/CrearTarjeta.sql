create
    definer = root@`%` procedure CrearTarjeta(IN p_cuenta_id bigint, IN p_tipo enum ('credito', 'debito'),
                                              IN p_limite decimal(15, 2), IN p_titular varchar(50), IN p_fecha datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_tarjeta_id BIGINT;
    DECLARE v_cuenta_existente INT;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Hacer rollback de la transacción
        ROLLBACK;

        -- Obtener detalles del error
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;

        -- Retornar el error en formato JSON con el mensaje heredado
        SELECT JSON_OBJECT(
            'status', 'error',
            'message', CONCAT('Ha ocurrido un error: ', v_error_message)
        ) AS resultado;
    END;

    -- Iniciar una transacción
    START TRANSACTION;

    -- Validar si la cuenta existe
    SELECT COUNT(*) INTO v_cuenta_existente
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_cuenta_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no está registrada';
    END IF;

    -- Validar que el límite sea mayor a 0
    IF p_limite <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El límite debe ser mayor a 0';
    END IF;

    -- Insertar la tarjeta con campos inicializados
    INSERT INTO tarjeta (
        tipo,
        limite,
        titular,
        monto,
        interes,
        tasa_interes,
        estado,
        vigencia,
        fecha_solicitud,
        cuenta_id
    ) VALUES (
        p_tipo,
        p_limite,
        p_titular,
        0.00,            -- monto inicializado a 0
        0.00,            -- interes inicializado a 0
        0.00,            -- tasa_interes inicializada a 0
        'pendiente',     -- estado inicial
        'activa',        -- vigencia inicial
        p_fecha,
        p_cuenta_id
    );

    -- Obtener el ID de la tarjeta recién creada
    SET v_tarjeta_id = LAST_INSERT_ID();

    -- Crear una solicitud para la tarjeta
    INSERT INTO solicitud (
        tarjeta_id,
        estado
    ) VALUES (
        v_tarjeta_id,
        'pendiente'      -- estado inicial de la solicitud
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la tarjeta creada y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'tarjeta_id', v_tarjeta_id,
        'state', 'pendiente',
        'message', 'Tarjeta creada exitosamente y solicitud registrada'
    ) AS resultado;

END;

