create
    definer = root@`%` procedure SolicitarPrestamo(IN p_cuenta_id_or_cui bigint, IN p_monto decimal(15, 2),
                                                   IN p_plazo int, IN p_fecha datetime, IN p_idtipo int,
                                                   IN p_cuota decimal(15, 2))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_tipo_existente INT;
    DECLARE v_prestamo_id BIGINT;
    DECLARE v_cuenta_id BIGINT;

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

    -- Determinar si es cuenta_id o cui
    SELECT cuenta_id INTO v_cuenta_id
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id_or_cui OR cui = p_cuenta_id_or_cui and vigencia = 'activa';

    IF v_cuenta_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no está registrada';
    END IF;

    -- Validar si el tipo de préstamo existe
    SELECT COUNT(*) INTO v_tipo_existente
    FROM tipo_prestamo
    WHERE tipo_prestamo_id = p_idtipo;

    IF v_tipo_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de préstamo no está registrado';
    END IF;

    -- Insertar el préstamo
    INSERT INTO prestamo (
        cuenta_id,
        monto,
        saldo,
        plazo_meses,
        fecha_solicitud,
        tipo_prestamo_id,
        cuota,
        estado
    ) VALUES (
        v_cuenta_id,
        p_cuota,
        p_monto,
        p_plazo,
        p_fecha,
        p_idtipo,
        p_cuota,
        'pendiente' -- estado inicial del préstamo
    );

    -- Obtener el ID del préstamo recién creado
    SET v_prestamo_id = LAST_INSERT_ID();

    -- Crear una solicitud para el préstamo
    INSERT INTO solicitud (
        prestamo_id,
        estado
    ) VALUES (
        v_prestamo_id,
        'pendiente' -- estado inicial de la solicitud
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID del préstamo y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'prestamo_id', v_prestamo_id,
        'state', 'pendiente',
        'message', 'Préstamo solicitado exitosamente'
    ) AS resultado;

END;

