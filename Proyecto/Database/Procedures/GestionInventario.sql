create
    definer = root@`%` procedure GestionInventario(IN p_sucursal_id int)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_dinero_total DECIMAL(15, 2);
    DECLARE v_dinero_quetzales DECIMAL(15, 2);
    DECLARE v_dinero_dolares DECIMAL(15, 2);
    DECLARE v_transacciones JSON;
    DECLARE v_suma_dolares DECIMAL(15, 2);
    DECLARE v_cambio_quetzal DECIMAL(15, 2);
    DECLARE v_sucursal int;

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

    -- Iniciar una transacción
    START TRANSACTION;


    SET v_dinero_quetzales = 0;
    SET v_dinero_dolares = 0;

    SELECT sucursal_id INTO v_sucursal
    FROM sucursal WHERE sucursal_id = p_sucursal_id;

    IF v_sucursal IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La Sucursal no existe';
    END IF;

    -- Obtener el dinero disponible total
    SELECT dinero_disponible INTO v_dinero_total FROM sucursal WHERE sucursal_id = p_sucursal_id;

    -- Obtener el cambio del dólar a quetzal
    SELECT cambio_quetzal INTO v_cambio_quetzal FROM moneda WHERE tipo = 'dolar';

    IF v_cambio_quetzal IS NULL THEN
        SET v_cambio_quetzal = 1;
    END IF;

    IF v_cambio_quetzal = 0 THEN
        SET v_cambio_quetzal = 1;
    END IF;

    -- Calcular el dinero en dólares
    SET v_dinero_dolares = v_dinero_total / v_cambio_quetzal;

    -- Obtener el arreglo de transacciones
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'transaccion_id', trans_id,
        'monto', monto,
        'tipo', tipo,
        'fecha', fecha,
        'moneda', (SELECT tipo FROM moneda WHERE moneda_id = t.moneda_id),
        'cuenta_id', cuenta_id
    )) INTO v_transacciones
    FROM transaccion t;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar los datos del inventario
    SELECT JSON_OBJECT(
        'status', 'success',
        'dinero_total', v_dinero_total,
        'dinero_quetzales', v_dinero_total,
        'dinero_dolares', v_dinero_dolares,
        'transacciones', v_transacciones
    ) AS resultado;

END;

