create
    definer = root@`%` procedure CrearCliente(IN p_nombres varchar(50), IN p_apellidos varchar(50), IN p_cui bigint,
                                              IN p_telefono bigint, IN p_correo varchar(100), IN p_direccion text,
                                              IN p_genero enum ('masculino', 'femenino'), IN p_link_foto varchar(200),
                                              IN p_fecha_nac datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cui_existente INT;

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

    -- Verificar si el CUI ya está registrado
    SELECT COUNT(*) INTO v_cui_existente
    FROM cliente
    WHERE cui = p_cui;

    IF v_cui_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El CUI ya está registrado';
    END IF;

    -- Insertar los datos del cliente
    INSERT INTO cliente (
        nombres,
        apellidos,
        cui,
        telefono,
        correo,
        direccion,
        genero,
        link_foto,
        fecha_nac
    ) VALUES (
        p_nombres,
        p_apellidos,
        p_cui,
        p_telefono,
        p_correo,
        p_direccion,
        p_genero,
        p_link_foto,
        p_fecha_nac
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el CUI del cliente creado y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'cui', p_cui,
        'message', 'Cliente creado exitosamente'
    ) AS resultado;

END;

