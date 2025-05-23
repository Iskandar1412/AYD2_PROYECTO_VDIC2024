create
    definer = root@`%` procedure CrearAdmin(IN p_cui bigint, IN p_2fa varchar(200))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;
    DECLARE v_id_administrador INT;

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

    -- Verificar si el empleado existe
    SELECT COUNT(*) INTO v_empleado_existente
    FROM empleado
    WHERE cui = p_cui and vigencia = 'activo';

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Insertar en la tabla administrador
    INSERT INTO administrador (
        `2FA`,
        cui
    ) VALUES (
        p_2fa,
        p_cui
    );

    -- Obtener el ID del administrador recién creado
    SET v_id_administrador = LAST_INSERT_ID();

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'id_admin', v_id_administrador,
        'message', 'Administrador creado exitosamente'
    ) AS resultado;

END;

