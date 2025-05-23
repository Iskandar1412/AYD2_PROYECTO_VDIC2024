create
    definer = root@`%` procedure BloquearTarjeta(IN p_tarjeta_id bigint, IN p_motivo enum ('robo', 'perdida', 'fraude'),
                                                 IN p_fecha datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_tarjeta_existente INT;

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

    -- Validar si la tarjeta existe
    SELECT COUNT(*) INTO v_tarjeta_existente
    FROM tarjeta
    WHERE tarjeta_id = p_tarjeta_id;

    IF v_tarjeta_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La tarjeta no está registrada';
    END IF;

    -- Actualizar la vigencia de la tarjeta
    UPDATE tarjeta
    SET vigencia = 'inactiva'
    WHERE tarjeta_id = p_tarjeta_id;

    -- Registrar el bloqueo de la tarjeta
    INSERT INTO bloqueo_tarjeta (
        fecha,
        motivo,
        tarjeta_id
    ) VALUES (
        p_fecha,
        p_motivo,
        p_tarjeta_id
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'inactiva',
        'message', 'Tarjeta bloqueada exitosamente'
    ) AS resultado;

END;

