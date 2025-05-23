create
    definer = root@`%` procedure mostrar_saldo(IN p_numero_cuenta bigint)
BEGIN
    DECLARE v_cuenta_id INT;
    DECLARE v_saldo DECIMAL(15, 2);
    DECLARE v_fecha_ultima_transaccion DATETIME;
    DECLARE v_error_message VARCHAR(255);

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Obtener detalles del error
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;

        -- Hacer rollback de la transacción
        ROLLBACK;

        -- Retornar el error en formato JSON con el mensaje heredado
        SELECT JSON_OBJECT(
            'status', 'error',
            'message', CONCAT('Ha ocurrido un error: ', v_error_message)
        ) AS resultado;
    END;

    -- Obtener la cuenta y el saldo
    SELECT c.cuenta_id, c.saldo
    INTO v_cuenta_id, v_saldo
    FROM cuenta c
    WHERE c.cuenta_id = p_numero_cuenta;

    -- Si no hay cuenta devolver error
    IF v_cuenta_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El id de la cuenta no existe';
    END IF;

    -- Obtener la fecha de la última transacción registrada
    SELECT MAX(t.fecha) INTO v_fecha_ultima_transaccion
    FROM transaccion t
    WHERE t.cuenta_id = v_cuenta_id;

    -- Si no hay transacciones, asignar NULL a la fecha
    IF v_fecha_ultima_transaccion IS NULL THEN
        SET v_fecha_ultima_transaccion = NULL;
    END IF;

    -- Retornar el saldo y la fecha de última transacción en formato JSON
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Saldo consultado exitosamente',
        'cuenta_id', v_cuenta_id,
        'saldo', v_saldo,
        'fecha_ultima_transaccion', IFNULL(DATE_FORMAT(v_fecha_ultima_transaccion, '%Y-%m-%d %H:%i:%s'), 'Sin transacciones')
    ) AS resultado;

END;
