create
    definer = root@`%` procedure Comentario(IN p_detalle varchar(150), IN p_categoria varchar(50),
                                            IN p_tipo enum ('queja', 'satisfaccion'), IN p_fecha datetime,
                                            IN p_puntuacion int, IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cliente_existente INT;
    DECLARE v_comentario_id INT;

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

    -- Validar si el cliente existe
    SELECT COUNT(*) INTO v_cliente_existente
    FROM cliente
    WHERE cui = p_cui;

    IF v_cliente_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no está registrado';
    END IF;

    -- Insertar el comentario
    INSERT INTO comentario (
        detalle,
        categoria,
        tipo,
        fecha,
        puntuacion,
        cui
    ) VALUES (
        p_detalle,
        p_categoria,
        p_tipo,
        p_fecha,
        p_puntuacion,
        p_cui
    );

    -- Obtener el ID del comentario recién creado
    SET v_comentario_id = LAST_INSERT_ID();

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID del comentario creado y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'comentario_id', v_comentario_id,
        'message', 'Comentario registrado exitosamente'
    ) AS resultado;

END;

