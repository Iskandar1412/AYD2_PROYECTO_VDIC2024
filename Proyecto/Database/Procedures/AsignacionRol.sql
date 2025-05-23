create
    definer = root@`%` procedure AsignacionRol(IN p_empleado_id bigint,
                                               IN p_rol enum ('supervisor', 'administrador', 'cajero', 'atencion'))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;

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
    WHERE cui = p_empleado_id and vigencia = 'activo';

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Actualizar el rol del empleado
    UPDATE empleado
    SET rol = p_rol
    WHERE cui = p_empleado_id;

    -- Asignar rol
    INSERT INTO cambio_empleado (cambio, fecha, cui)
    VALUES (CONCAT('Asignacion de rol', p_rol), NOW(), p_empleado_id);

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Rol asignado exitosamente'
    ) AS resultado;

END;

