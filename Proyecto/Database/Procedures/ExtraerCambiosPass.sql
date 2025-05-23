create
    definer = root@`%` procedure ExtraerCambiosPass()
BEGIN
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

    -- Seleccionar todos los cambios de contraseña pendientes
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'cambio_pass_id', cambio_pass_id,
        'cui', cui,
        'estado', estado
    )) AS cambios
    FROM cambio_pass
    WHERE estado = 'pendiente';

END;

