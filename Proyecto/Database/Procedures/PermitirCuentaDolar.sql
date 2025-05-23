create
    definer = root@`%` procedure PermitirCuentaDolar(IN p_cuenta_id bigint, IN p_fecha datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cuenta_existente INT;

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

    -- Validar si la cuenta existe
    SELECT COUNT(*) INTO v_cuenta_existente
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_cuenta_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no está registrada';
    END IF;

    -- Registrar la cuenta en dólares
    INSERT INTO cuenta_dolar (
        fecha_apertura,
        cuenta_id
    ) VALUES (
        p_fecha,
        p_cuenta_id
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Cuenta en dólares permitida exitosamente'
    ) AS resultado;

END;

