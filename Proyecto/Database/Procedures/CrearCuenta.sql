create
    definer = root@`%` procedure CrearCuenta(IN p_saldo decimal(15, 2), IN p_tipo enum ('ahorro', 'monetaria'),
                                             IN p_fecha_apertura datetime, IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_cliente_existente INT;

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

    -- Validar si el cliente existe
    SELECT COUNT(*) INTO v_cliente_existente
    FROM cliente
    WHERE cui = p_cui;

    IF v_cliente_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no está registrado';
    END IF;
    
    -- Validar que el saldo inicial sea positivo
    IF p_saldo < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El saldo inicial debe ser positivo';
    END IF;

    -- Insertar la cuenta
    INSERT INTO cuenta (
        saldo,
        tipo,
        fecha_apertura,
        vigencia,
        cui
    ) VALUES (
        p_saldo,
        p_tipo,
        p_fecha_apertura,
        'activa',
        p_cui
    );

    -- Obtener el ID de la cuenta recién creada
    SET v_cuenta_id = LAST_INSERT_ID();
    
     -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible + p_saldo
    WHERE sucursal_id = 1;
    
    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la cuenta creada y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'cuenta_id', v_cuenta_id,
        'message', 'Cuenta creada exitosamente'
    ) AS resultado;

END;

