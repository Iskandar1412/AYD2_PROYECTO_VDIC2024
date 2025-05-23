create
    definer = root@`%` procedure CancelacionCuenta(IN p_cuenta_id bigint, IN p_motivo varchar(100), IN p_fecha datetime,
                                                   IN p_tipo enum ('tarjeta', 'cuenta'))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cancelacion_id INT;
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

    -- Registrar la cancelación de la cuenta
    INSERT INTO cancelacion (
        motivo,
        fecha_solicitud,
        tipo,
        estado,
        cuenta_id
    ) VALUES (
        p_motivo,
        p_fecha,
        p_tipo,
        'pendiente',    -- estado inicial de la cancelación
        p_cuenta_id
    );

    -- Obtener el ID de la cancelación recién creada
    SET v_cancelacion_id = LAST_INSERT_ID();

    -- Crear una solicitud para la cancelación
    INSERT INTO solicitud (
        cancelacion_id,
        estado
    ) VALUES (
        v_cancelacion_id,
        'pendiente'      -- estado inicial de la solicitud
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la cancelación y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'cancelacion_id', v_cancelacion_id,
        'state', 'pendiente',
        'message', 'Cancelación de cuenta registrada exitosamente'
    ) AS resultado;

END;

