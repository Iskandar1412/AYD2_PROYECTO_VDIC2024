create
    definer = root@`%` procedure LoginAdm2fa(IN p_id_admin int, IN p_2fa varchar(200))
BEGIN
    DECLARE v_2fa_stored VARCHAR(200);
    DECLARE v_error_message VARCHAR(255);

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

    -- Verificar si el administrador existe y obtener su 2FA
    SELECT `2FA`
    INTO v_2fa_stored
    FROM administrador
    WHERE id_administrador = p_id_admin;

    -- Si no se encuentra el administrador, retornar error
    IF v_2fa_stored IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Administrador no encontrado';
    END IF;

    -- Verificar si el código 2FA coincide
    IF v_2fa_stored != p_2fa THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Código 2FA incorrecto';
    END IF;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Autenticación 2FA exitosa'
    ) AS resultado;

END;

