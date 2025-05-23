create
    definer = root@`%` procedure LoginSupe2pass(IN p_supervisor_id int, IN p_password2 varchar(200))
BEGIN
    DECLARE v_password2_hash VARCHAR(200);
    DECLARE v_password2_input_hash VARCHAR(200);
    DECLARE v_error_message VARCHAR(255);

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

    -- Verificar si el supervisor existe y obtener la segunda contraseña
    SELECT password2
    INTO v_password2_hash
    FROM supervisor
    WHERE supervisor_id = p_supervisor_id;

    -- Si no se encuentra el supervisor, retornar error
    IF v_password2_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Supervisor no encontrado';
    END IF;

    -- Generar el hash SHA-256 de la segunda contraseña proporcionada
    SET v_password2_input_hash = SHA2(p_password2, 256);

    -- Verificar si la segunda contraseña coincide con la almacenada (compara los hashes)
    IF v_password2_hash != v_password2_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Segunda contraseña incorrecta';
    END IF;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Segunda contraseña autenticada exitosamente'
    ) AS resultado;

END;

