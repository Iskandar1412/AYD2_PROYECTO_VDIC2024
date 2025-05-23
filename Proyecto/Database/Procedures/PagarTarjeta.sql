create
    definer = root@`%` procedure PagarTarjeta(IN p_monto decimal(15, 2), IN p_fecha datetime, IN p_cuenta_id bigint,
                                              IN p_tarjeta_id bigint, IN p_moneda_id int, IN p_encargado_cui bigint)
BEGIN
    DECLARE v_trans_id BIGINT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_moneda_tipo VARCHAR(25);
    DECLARE v_saldo_actual DECIMAL(15, 2);
    DECLARE v_tarjeta_existente INT;
    DECLARE v_moneda_existente INT;
    DECLARE v_encargado_existente INT;
    DECLARE v_cambio_quetzal DECIMAL(15, 2);
    DECLARE v_monto_en_quetzales DECIMAL(15, 2);

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

    -- Validar si la tarjeta existe
    SELECT COUNT(*) INTO v_tarjeta_existente
    FROM tarjeta
    WHERE tarjeta_id = p_tarjeta_id;

    IF v_tarjeta_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tarjeta no encontrada';
    END IF;

    -- Validar si la moneda existe y obtener el tipo y el cambio
    SELECT COUNT(*), tipo, cambio_quetzal INTO v_moneda_existente, v_moneda_tipo, v_cambio_quetzal
    FROM moneda
    WHERE moneda_id = p_moneda_id
    GROUP BY tipo, cambio_quetzal;

    IF v_moneda_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Moneda no encontrada';
    END IF;

    -- Calcular el monto en quetzales si es en dólares
    IF v_moneda_tipo = 'dolar' THEN
        SET v_monto_en_quetzales = p_monto * v_cambio_quetzal;
    ELSE
        SET v_monto_en_quetzales = p_monto;
    END IF;

    -- Validar si la cuenta existe y tiene saldo suficiente
    SELECT saldo INTO v_saldo_actual
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    IF v_saldo_actual < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;

    -- Validar si el encargado existe
    SELECT COUNT(*) INTO v_encargado_existente
    FROM empleado
    WHERE cui = p_encargado_cui;

    IF v_encargado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El encargado no existe como empleado';
    END IF;

    -- Registrar el pago de la tarjeta
    INSERT INTO transaccion (
        monto,
        tipo,
        fecha,
        cuenta_id,
        tarjeta_id,
        moneda_id,
        empleado_cui
    ) VALUES (
        v_monto_en_quetzales,
        'pago_tarjeta',
        p_fecha,
        p_cuenta_id,
        p_tarjeta_id,
        p_moneda_id,
        p_encargado_cui
    );

    -- Obtener el ID de la transacción recién creada
    SET v_trans_id = LAST_INSERT_ID();

    -- Actualizar el saldo de la cuenta
    UPDATE cuenta
    SET saldo = saldo - v_monto_en_quetzales
    WHERE cuenta_id = p_cuenta_id;

    -- Actualizar el monto e interés de la tarjeta a 0
    UPDATE tarjeta
    SET monto = 0, interes = 0
    WHERE tarjeta_id = p_tarjeta_id;
    
     -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible + v_monto_en_quetzales
    WHERE sucursal_id = 1;


    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la transacción y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'trans_id', v_trans_id,
        'message', 'Pago de tarjeta realizado con éxito'
    ) AS resultado;

END;

