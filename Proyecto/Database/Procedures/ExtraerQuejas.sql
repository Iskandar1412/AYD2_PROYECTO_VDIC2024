create
    definer = root@`%` procedure ExtraerQuejas()
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

    -- Seleccionar todas las quejas
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'comentario_id', comentario_id,
        'detalle', detalle,
        'categoria', categoria,
        'fecha', fecha,
        'puntuacion', puntuacion,
        'cui', cui
    )) AS quejas
    FROM comentario
    WHERE tipo = 'queja';

END;

