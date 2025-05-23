create
    definer = root@`%` procedure RegistrarEmpleado(IN p_cui bigint, IN p_nombres varchar(50),
                                                   IN p_apellidos varchar(50), IN p_telefono bigint,
                                                   IN p_fecha_nac datetime, IN p_correo varchar(100),
                                                   IN p_usuario varchar(50), IN p_password varchar(200),
                                                   IN p_link_foto varchar(200),
                                                   IN p_genero enum ('masculino', 'femenino'),
                                                   IN p_estado_civil enum ('soltero', 'casado'), IN p_sucursal_id int)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_sucursal_existente INT;
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

    -- Validar si la sucursal existe
    SELECT COUNT(*) INTO v_sucursal_existente
    FROM sucursal
    WHERE sucursal_id = p_sucursal_id;

    IF v_sucursal_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La sucursal no está registrada';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_hashed = SHA2(p_password, 256);

    -- Registrar el empleado
    INSERT INTO empleado (
        cui,
        usuario,
        password,
        nombres,
        apellidos,
        telefono,
        correo,
        link_foto,
        genero,
        estado_civil,
        fecha_nac,
        vigencia,
        rol,
        sucursal_id
    ) VALUES (
        p_cui,
        p_usuario,
        v_password_hashed,
        p_nombres,
        p_apellidos,
        p_telefono,
        p_correo,
        p_link_foto,
        p_genero,
        p_estado_civil,
        p_fecha_nac,
        'activo',
        'pendiente', -- rol inicial
        p_sucursal_id
    );

    -- Registro de empleado
    INSERT INTO cambio_empleado (cambio, fecha, cui)
    VALUES ('Registro de empleado', NOW(), p_cui);

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Empleado registrado exitosamente'
    ) AS resultado;

END;

