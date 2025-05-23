create
    definer = root@`%` procedure RevisarCancelacion(IN p_cancelacion_id int, IN p_estado enum ('aceptado', 'rechazado'),
                                                    IN p_justificacion varchar(255))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_solicitud_existente INT;
    DECLARE v_tipo ENUM('tarjeta', 'cuenta');
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_tarjeta_id BIGINT;
    DECLARE v_monto_tarjeta DECIMAL(15, 2);
    DECLARE v_saldo_prestamo DECIMAL(15, 2);

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

    -- Verificar si la solicitud de la cancelación existe
    SELECT COUNT(*), tipo, cuenta_id, tarjeta_id
    INTO v_solicitud_existente, v_tipo, v_cuenta_id, v_tarjeta_id
    FROM solicitud
    JOIN cancelacion ON solicitud.cancelacion_id = cancelacion.cancelacion_id
    WHERE solicitud.cancelacion_id = p_cancelacion_id
    group by tipo, cuenta_id, tarjeta_id ;

    IF v_solicitud_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La solicitud de cancelación no existe';
    END IF;

    -- Si la cancelación es aceptada, realizar validaciones adicionales
    IF p_estado = 'aceptado' THEN
        IF v_tipo = 'tarjeta' THEN
            -- Verificar que la tarjeta no tenga monto pendiente
            SELECT monto INTO v_monto_tarjeta
            FROM tarjeta
            WHERE tarjeta_id = v_tarjeta_id;

            IF v_monto_tarjeta > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La tarjeta tiene un monto pendiente';
            END IF;

            -- Cambiar la vigencia de la tarjeta a "inactiva"
            UPDATE tarjeta
            SET vigencia = 'inactiva'
            WHERE tarjeta_id = v_tarjeta_id;

        ELSEIF v_tipo = 'cuenta' THEN
            -- Verificar que la cuenta no tenga préstamos pendientes
            SELECT SUM(saldo) INTO v_saldo_prestamo
            FROM prestamo
            WHERE cuenta_id = v_cuenta_id;

            IF v_saldo_prestamo > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La cuenta tiene préstamos pendientes';
            END IF;

            -- Cambiar la vigencia de la cuenta a "inactiva"
            UPDATE cuenta
            SET vigencia = 'inactiva'
            WHERE cuenta_id = v_cuenta_id;
        END IF;
    END IF;

    -- Actualizar el estado de la solicitud
    UPDATE solicitud
    SET estado = p_estado, justificacion = p_justificacion
    WHERE cancelacion_id = p_cancelacion_id;

    -- Actualizar el estado de la cancelación
    UPDATE cancelacion
    SET estado = p_estado
    WHERE cancelacion_id = p_cancelacion_id;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', CONCAT('Cancelación ', p_estado, ' exitosamente')
    ) AS resultado;

END;

