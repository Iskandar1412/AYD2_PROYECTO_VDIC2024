create
    definer = root@`%` procedure Monitoreo()
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

    -- Obtener los contadores
    SELECT JSON_OBJECT(
        'retiros', (SELECT COUNT(*) FROM transaccion WHERE tipo = 'retiro'),
        'solicitud_prestamos', (SELECT COUNT(*) FROM solicitud WHERE prestamo_id IS NOT NULL),
        'bloqueos', (SELECT COUNT(*) FROM bloqueo_tarjeta),
        'solicitud_tarjetas', (SELECT COUNT(*) FROM solicitud WHERE tarjeta_id IS NOT NULL),
        'despidos', (SELECT COUNT(*) FROM despido WHERE estado = 'realizado'),
        'cambios_contrasena', (SELECT COUNT(*) FROM cambio_pass WHERE estado = 'realizado')
    ) AS monitoreo;

END;

