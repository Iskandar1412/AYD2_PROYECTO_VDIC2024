create
    definer = root@`%` procedure ExtraerSolicitudes()
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

    -- Seleccionar todas las solicitudes pendientes
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'solicitud_id', solicitud_id,
        'prestamo_id', prestamo_id,
        'tarjeta_id', tarjeta_id,
        'cancelacion_id', cancelacion_id,
        'estado', estado
    )) AS solicitudes
    FROM solicitud
    WHERE estado = 'pendiente';

END;

