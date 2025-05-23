create
    definer = root@`%` procedure CambioPassWEmpleado(IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cambio_existente INT;
    DECLARE v_password VARCHAR(200);

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

    -- Verificar si hay una solicitud pendiente de cambio de contraseña
    SELECT COUNT(*), password INTO v_cambio_existente, v_password
    FROM cambio_pass
    WHERE cui = p_cui AND estado = 'pendiente'
    group by password ;

    IF v_cambio_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay una solicitud pendiente de cambio de contraseña para este empleado';
    END IF;

    -- Actualizar la contraseña en la tabla empleado
    UPDATE empleado
    SET password = v_password
    WHERE cui = p_cui;

    -- Cambiar el estado de la solicitud de cambio de contraseña a 'realizado'
    UPDATE cambio_pass
    SET estado = 'realizado',
    fecha = NOW()
    WHERE cui = p_cui;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'realizado',
        'message', 'Contraseña actualizada exitosamente'
    ) AS resultado;

END;

