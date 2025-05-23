create
    definer = root@`%` procedure CambioPassWEmpleadoSolicitud(IN p_password varchar(200), IN p_cui bigint)
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
    WHERE cui = p_cui and vigencia='activo';

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Generar el hash SHA-256 de la nueva contraseña
    SET v_password_hashed = SHA2(p_password, 256);

    -- Insertar la solicitud de cambio de contraseña
    INSERT INTO cambio_pass (
        password,
        estado,
        cui
    ) VALUES (
        v_password_hashed,
        'pendiente', -- estado inicial de la solicitud
        p_cui
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'pendiente',
        'message', 'Solicitud de cambio de contraseña registrada exitosamente'
    ) AS resultado;

END;

