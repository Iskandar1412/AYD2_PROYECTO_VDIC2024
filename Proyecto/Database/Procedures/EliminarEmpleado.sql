create
    definer = root@`%` procedure EliminarEmpleado(IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_despido_existente INT;
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

    -- Validar si el despido está registrado
    SELECT COUNT(*) INTO v_despido_existente
    FROM despido
    WHERE cui = p_cui AND estado = 'pendiente';

    IF v_despido_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay una solicitud pendiente para este empleado';
    END IF;

    -- Validar si el empleado existe
    SELECT COUNT(*) INTO v_empleado_existente
    FROM empleado
    WHERE cui = p_cui;

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Actualizar el estado del despido a 'realizado'
    UPDATE despido
    SET 
        estado = 'realizado',
        fecha = NOW()
    WHERE cui = p_cui;

    -- Cambiar la vigencia del empleado a 'inactivo'
    UPDATE empleado
    SET vigencia = 'inactivo'
    WHERE cui = p_cui;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'realizado',
        'message', 'El empleado ha sido eliminado exitosamente'
    ) AS resultado;

END;

