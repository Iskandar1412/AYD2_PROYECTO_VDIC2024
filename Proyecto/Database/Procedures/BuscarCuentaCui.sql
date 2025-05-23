create
    definer = root@`%` procedure BuscarCuentaCui(IN p_input bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_nombres VARCHAR(50);
    DECLARE v_apellidos VARCHAR(50);
    DECLARE v_tipo ENUM('ahorro', 'monetaria');

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

    -- Buscar la cuenta y datos del cliente
    SELECT c.cuenta_id, cl.nombres, cl.apellidos, c.tipo
    INTO v_cuenta_id, v_nombres, v_apellidos, v_tipo
    FROM cuenta c
    JOIN cliente cl ON c.cui = cl.cui
    WHERE c.cuenta_id = p_input OR cl.cui = p_input and c.vigencia = 'activa';

    -- Si no se encuentra la cuenta, retornar error
    IF v_cuenta_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta o cliente no encontrado';
    END IF;

    -- Obtener las transacciones asociadas
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'trans_id', t.trans_id,
            'monto', t.monto,
            'tipo', t.tipo,
            'fecha', t.fecha
        )
    ) AS transacciones
    FROM transaccion t
    WHERE t.cuenta_id = v_cuenta_id
    INTO @transacciones;

    -- Retornar los datos y las transacciones
    SELECT JSON_OBJECT(
        'status', 'success',
        'cuenta_id', v_cuenta_id,
        'nombres', v_nombres,
        'apellidos', v_apellidos,
        'tipo', v_tipo,
        'transacciones', COALESCE(@transacciones, JSON_ARRAY()),
        'message', 'Consulta exitosa'
    ) AS resultado;

END;

