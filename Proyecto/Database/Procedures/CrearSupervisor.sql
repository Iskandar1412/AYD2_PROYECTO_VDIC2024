create
    definer = root@`%` procedure CrearSupervisor(IN p_cui bigint, IN p_usuario varchar(50), IN p_password varchar(200),
                                                 IN p_password2 varchar(200))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;
    DECLARE v_password_hashed VARCHAR(200);

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

    -- Validar si el empleado existe
    SELECT COUNT(*) INTO v_empleado_existente
    FROM empleado
    WHERE cui = p_cui;

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Verificar que las contraseñas coincidan
    IF p_password != p_password2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Las contraseñas no coinciden';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_hashed = SHA2(p_password, 256);

    -- Insertar el registro en la tabla supervisor
    INSERT INTO supervisor (
        usuario,
        password,
        password2,
        cui
    ) VALUES (
        p_usuario,
        v_password_hashed,
        SHA2(p_password2, 256), -- Encriptar también la segunda contraseña
        p_cui
    );

    -- Actualizar el rol en la tabla empleado
    UPDATE empleado
    SET rol = 'supervisor'
    WHERE cui = p_cui;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'supervisor_id', LAST_INSERT_ID(),
        'message', 'Supervisor creado exitosamente'
    ) AS resultado;

END;

