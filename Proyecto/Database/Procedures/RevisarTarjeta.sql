create
    definer = root@`%` procedure RevisarTarjeta(IN p_tarjeta_id bigint, IN p_estado enum ('aceptado', 'rechazado'),
                                                IN p_justificacion varchar(255))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_solicitud_existente INT;

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

    -- Verificar si la solicitud de la tarjeta existe
    SELECT COUNT(*) INTO v_solicitud_existente
    FROM solicitud
    WHERE tarjeta_id = p_tarjeta_id;

    IF v_solicitud_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La solicitud de la tarjeta no existe';
    END IF;

    -- Actualizar el estado de la solicitud
    UPDATE solicitud
    SET estado = p_estado, justificacion = p_justificacion
    WHERE tarjeta_id = p_tarjeta_id;

    -- Actualizar el estado de la tarjeta
    UPDATE tarjeta
    SET estado = p_estado
    WHERE tarjeta_id = p_tarjeta_id;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', CONCAT('Tarjeta ', p_estado, ' exitosamente')
    ) AS resultado;

END;

