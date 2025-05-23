create
    definer = root@`%` procedure crear_cuenta(IN p_saldo_inicial decimal(15, 2), IN p_tipo VARCHAR(8),
                                              p_fecha_apertura DATETIME, p_vigencia VARCHAR(8),
                                              p_cui BIGINT)
BEGIN
    DECLARE v_usuario_existe INT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_valor_tipo TEXT;
    DECLARE v_valor_vigencia TEXT;
    DECLARE v_cuenta_id BIGINT;

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

    -- Iniciar transacción
    START TRANSACTION;

    -- Verificar que el monto sea positivo
    IF p_saldo_inicial < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El saldo inicial debe ser positivo';
    END IF;

    -- Verificar que el usuario existe
    SELECT COUNT(*) INTO v_usuario_existe
    FROM cliente
    WHERE cui = p_cui;

    IF v_usuario_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    -- Verificar tipo de cuenta
    SELECT REPLACE(SUBSTRING(COLUMN_TYPE, 6, LENGTH(COLUMN_TYPE) - 6), '\'', '')
    INTO v_valor_tipo
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'cuenta'
    AND COLUMN_NAME = 'tipo'
    AND TABLE_SCHEMA = DATABASE();

    IF FIND_IN_SET(p_tipo, v_valor_tipo) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de cuenta es incorrecto';
    END IF;

    -- Verificar Vigencia
    SELECT REPLACE(SUBSTRING(COLUMN_TYPE, 6, LENGTH(COLUMN_TYPE) - 6), '\'', '')
    INTO v_valor_vigencia
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'cuenta'
    AND COLUMN_NAME = 'vigencia'
    AND TABLE_SCHEMA = DATABASE();

    IF FIND_IN_SET(p_vigencia, v_valor_vigencia) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La vigencia de la cuenta es incorrecta';
    END IF;

    -- Crear la cuenta con el saldo inicial
    INSERT INTO cuenta (saldo, tipo, fecha_apertura, vigencia, cui)
    VALUES (p_saldo_inicial, p_tipo, p_fecha_apertura, p_vigencia, p_cui);

    -- Commit de la transacción
    COMMIT;

    SET v_cuenta_id = LAST_INSERT_ID();

    -- Retornar respuesta exitosa
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Cuenta registrada exitosamente',
        'cui', p_cui,
        'cuenta_id', v_cuenta_id,
        'saldo_inicial', p_saldo_inicial
    ) AS resultado;

END