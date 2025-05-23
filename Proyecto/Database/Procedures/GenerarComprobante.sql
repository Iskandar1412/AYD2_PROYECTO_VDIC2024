create
    definer = root@`%` procedure GenerarComprobante(IN p_trans_id bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_tipo VARCHAR(25);
    DECLARE v_fecha DATETIME;
    DECLARE v_monto DECIMAL(15, 2);
    DECLARE v_tipomoneda VARCHAR(25);
    DECLARE v_nombre_encargado VARCHAR(100);

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

    -- Obtener los datos de la transacción
    SELECT t.cuenta_id, t.tipo, t.fecha, t.monto, m.tipo, CONCAT(e.nombres, ' ', e.apellidos)
    INTO v_cuenta_id, v_tipo, v_fecha, v_monto, v_tipomoneda, v_nombre_encargado
    FROM transaccion t
    JOIN moneda m ON t.moneda_id = m.moneda_id
    JOIN empleado e ON t.empleado_cui = e.cui
    WHERE t.trans_id = p_trans_id;

    -- Validar si la transacción existe
    IF v_cuenta_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transacción no encontrada';
    END IF;

    -- Retornar los datos del comprobante
    SELECT JSON_OBJECT(
        'status', 'success',
        'cuenta_id', v_cuenta_id,
        'tipo', v_tipo,
        'fecha', v_fecha,
        'monto', v_monto,
        'tipomoneda', v_tipomoneda,
        'nombre_encargado', v_nombre_encargado,
        'message', 'Comprobante generado exitosamente'
    ) AS resultado;

END;

