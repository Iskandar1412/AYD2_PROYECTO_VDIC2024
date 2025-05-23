create
    definer = root@`%` procedure ExtraerAdministradores()
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

    -- Seleccionar los administradores y detalles de sus empleados
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'cui', a.cui,
        'usuario', e.usuario,
        'nombres', e.nombres,
        'apellidos', e.apellidos
    )) AS administradores
    FROM administrador a
    JOIN empleado e ON a.cui = e.cui
    WHERE e.vigencia = 'activo';

END;

