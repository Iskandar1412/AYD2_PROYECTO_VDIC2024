create
    definer = root@`%` procedure RetirarDinero(IN p_monto decimal(15, 2), IN p_fecha datetime, IN p_cuenta_id bigint,
                                               IN p_retiro_id int, IN p_moneda_id int, IN p_encargado_id bigint)
BEGIN
    DECLARE v_trans_id BIGINT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_moneda_tipo VARCHAR(25);
    DECLARE v_saldo_actual DECIMAL(15, 2);
    DECLARE v_saldo_sucursal DECIMAL(15, 2);
    DECLARE v_dolar_cuenta_id BIGINT;
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

    -- Validar si la moneda existe y obtener el tipo y el cambio
    SELECT COUNT(*), tipo, cambio_quetzal INTO v_moneda_existente, v_moneda_tipo, v_cambio_quetzal
    FROM moneda
    WHERE moneda_id = p_moneda_id
    group by tipo, cambio_quetzal ;

    IF v_moneda_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Moneda no encontrada';
    END IF;

    -- Calcular el monto en quetzales si es en dólares
    IF v_moneda_tipo = 'dolar' THEN
        SET v_monto_en_quetzales = p_monto * v_cambio_quetzal;

        -- Verificar si la cuenta tiene una cuenta en dólares asociada
        SELECT cuenta_dolar_id INTO v_dolar_cuenta_id
        FROM cuenta_dolar
        WHERE cuenta_id = p_cuenta_id;

        IF v_dolar_cuenta_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cuenta no está asociada a una cuenta en dólares';
        END IF;

        -- Verificar que no supere el límite en quetzales equivalentes
        IF v_monto_en_quetzales > 10000 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se pueden retirar más de 10000 quetzales en dólares';
        END IF;
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

    -- Validar si hay suficiente dinero en la sucursal
    SELECT dinero_disponible INTO v_saldo_sucursal
    FROM sucursal
    WHERE sucursal_id = 1;

    IF v_saldo_sucursal IS NULL OR v_saldo_sucursal < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente en la sucursal';
    END IF;

    -- Validar si el encargado existe
    SELECT COUNT(*) INTO v_encargado_existente
    FROM empleado
    WHERE cui = p_encargado_id;

    IF v_encargado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El encargado no existe como empleado';
    END IF;

    -- Registrar el retiro
    INSERT INTO transaccion (
        monto,
        tipo,
        fecha,
        cuenta_id,
        retiro_id,
        moneda_id,
        empleado_cui
    ) VALUES (
        v_monto_en_quetzales,
        'retiro',
        p_fecha,
        p_cuenta_id,
        p_retiro_id,
        p_moneda_id,
        p_encargado_id
    );

    -- Obtener el ID de la transacción recién creada
    SET v_trans_id = LAST_INSERT_ID();

    -- Actualizar el saldo de la cuenta
    UPDATE cuenta
    SET saldo = saldo - v_monto_en_quetzales
    WHERE cuenta_id = p_cuenta_id;

    -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible - v_monto_en_quetzales
    WHERE sucursal_id = 1;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la transacción y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'trans_id', v_trans_id,
        'message', 'Retiro realizado con éxito'
    ) AS resultado;

END;

