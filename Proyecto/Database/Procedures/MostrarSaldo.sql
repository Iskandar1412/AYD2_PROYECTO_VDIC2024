create
    definer = root@`%` procedure MostrarSaldo(IN p_cuenta_id bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_saldo DECIMAL(15, 2);
    DECLARE v_fecha_ultima_trans DATETIME;

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

    -- Validar si la cuenta existe y obtener el saldo
    SELECT saldo INTO v_saldo
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    -- Obtener la fecha de la última transacción
    SELECT MAX(fecha) INTO v_fecha_ultima_trans
    FROM transaccion
    WHERE cuenta_id = p_cuenta_id;

    -- Retornar el saldo y la fecha de la última transacción
    SELECT JSON_OBJECT(
        'status', 'success',
        'saldo', v_saldo,
        'ultima_transaccion', COALESCE(v_fecha_ultima_trans, 'No hay transacciones'),
        'message', 'Consulta exitosa'
    ) AS resultado;

END;

