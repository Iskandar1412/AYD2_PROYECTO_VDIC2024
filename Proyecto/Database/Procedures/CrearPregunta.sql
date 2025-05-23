create
    definer = root@`%` procedure CrearPregunta(IN p_pregunta_encrip text, IN p_respuesta_encrip text,
                                               IN p_cuenta_id bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_pregunta_id BIGINT;
    DECLARE v_cuenta_existente INT;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
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

    -- Insertar la pregunta de seguridad
    INSERT INTO pregunta_seguridad (
        pregunta_encrip,
        respuesta_encrip,
        cuenta_id
    ) VALUES (
        p_pregunta_encrip,
        p_respuesta_encrip,
        p_cuenta_id
    );

    -- Obtener el ID de la pregunta recién creada
    SET v_pregunta_id = LAST_INSERT_ID();

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la pregunta creada y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'pregunta_id', v_pregunta_id,
        'message', 'Pregunta de seguridad creada exitosamente'
    ) AS resultado;

END;

