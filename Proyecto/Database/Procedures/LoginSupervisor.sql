create
    definer = root@`%` procedure LoginSupervisor(IN p_usuario varchar(50), IN p_password varchar(200))
BEGIN
    DECLARE v_supervisor_id INT;
    DECLARE v_password_hash VARCHAR(200);
    DECLARE v_password_input_hash VARCHAR(200);
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

    -- Verificar si el usuario existe y obtener sus datos
    SELECT supervisor_id, password
    INTO v_supervisor_id, v_password_hash
    FROM supervisor
    WHERE usuario = p_usuario;

    -- Si no se encuentra el usuario, retornar error
    IF v_password_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario no encontrado';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_input_hash = SHA2(p_password, 256);

    -- Verificar si la contraseña coincide con la almacenada (compara los hashes)
    IF v_password_hash != v_password_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
    END IF;

    -- Retornar el supervisor_id si la autenticación es exitosa
    SELECT JSON_OBJECT(
        'status', 'success',
        'supervisor_id', v_supervisor_id,
        'message', 'Autenticación exitosa'
    ) AS resultado;

END;

