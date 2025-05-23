create
    definer = root@`%` procedure Login(IN p_input varchar(100), IN p_password varchar(200))
BEGIN
    DECLARE v_cui BIGINT;
    DECLARE v_usuario VARCHAR(50);
    DECLARE v_password_hash VARCHAR(200);
    DECLARE v_password_input_hash VARCHAR(200);
    DECLARE v_rol ENUM('supervisor', 'administrador', 'cajero', 'atencion');
    DECLARE v_vigencia ENUM('activo', 'inactivo');
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

    -- Verificar si el usuario o correo existe y obtener sus datos
    SELECT cui, usuario, password, rol, vigencia
    INTO v_cui, v_usuario, v_password_hash, v_rol, v_vigencia
    FROM empleado
    WHERE (usuario = p_input OR correo = p_input);

    -- Si no se encuentra el usuario/correo, retornar error
    IF v_password_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario o correo no encontrado';
    END IF;

    -- Verificar si el empleado está activo
    IF v_vigencia = 'inactivo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta del empleado está inactiva';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_input_hash = SHA2(p_password, 256);

    -- Verificar si la contraseña coincide con la almacenada (compara los hashes)
    IF v_password_hash != v_password_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
    END IF;

    -- Retornar el cui, usuario y rol si la autenticación es exitosa
    SELECT JSON_OBJECT(
        'status', 'success',
        'cui', v_cui,
        'usuario', v_usuario,
        'rol', v_rol,
        'message', 'Autenticación exitosa'
    ) AS resultado;

END;

