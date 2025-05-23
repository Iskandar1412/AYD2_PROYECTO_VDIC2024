create
    definer = root@`%` procedure ExtraerDespidos()
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

    -- Seleccionar todos los despidos pendientes
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'despido_id', despido_id,
        'link_doc', link_doc,
        'estado', estado,
        'cui', cui
    )) AS despidos
    FROM despido
    WHERE estado = 'pendiente';

END;

