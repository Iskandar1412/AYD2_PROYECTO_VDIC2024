create
    definer = root@`%` procedure LoginAdmin(IN p_input varchar(100), IN p_password varchar(200))
BEGIN
    DECLARE v_cui BIGINT;
    DECLARE v_usuario VARCHAR(50);
    DECLARE v_password_hash VARCHAR(200);
    DECLARE v_password_input_hash VARCHAR(200);
    DECLARE v_id_administrador INT;
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

    -- Verificar si el usuario o CUI existe y obtener sus datos
    SELECT e.cui, e.usuario, e.password, a.id_administrador
    INTO v_cui, v_usuario, v_password_hash, v_id_administrador
    FROM empleado e
    JOIN administrador a ON e.cui = a.cui
    WHERE e.usuario = p_input OR e.cui = p_input AND e.vigencia = 'activo';

    -- Si no se encuentra el usuario/cui, retornar error
    IF v_password_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario o CUI no encontrado';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_input_hash = SHA2(p_password, 256);

    -- Verificar si la contraseña coincide con la almacenada (compara los hashes)
    IF v_password_hash != v_password_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
    END IF;

    -- Retornar el ID del administrador y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'id_admin', v_id_administrador,
        'message', 'Autenticación exitosa'
    ) AS resultado;

END;

