create
    definer = root@`%` procedure CancelacionTarjeta(IN p_tarjeta_id bigint, IN p_motivo varchar(100),
                                                    IN p_fecha datetime, IN p_tipo enum ('tarjeta', 'cuenta'))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cancelacion_id INT;
    DECLARE v_tarjeta_existente INT;

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

    -- Validar si la tarjeta existe
    SELECT COUNT(*) INTO v_tarjeta_existente
    FROM tarjeta
    WHERE tarjeta_id = p_tarjeta_id;

    IF v_tarjeta_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La tarjeta no está registrada';
    END IF;

    -- Registrar la cancelación de la tarjeta
    INSERT INTO cancelacion (
        motivo,
        fecha_solicitud,
        tipo,
        estado,
        tarjeta_id
    ) VALUES (
        p_motivo,
        p_fecha,
        p_tipo,
        'pendiente',    -- estado inicial de la cancelación
        p_tarjeta_id
    );

    -- Obtener el ID de la cancelación recién creada
    SET v_cancelacion_id = LAST_INSERT_ID();

    -- Crear una solicitud para la cancelación
    INSERT INTO solicitud (
        cancelacion_id,
        estado
    ) VALUES (
        v_cancelacion_id,
        'pendiente'      -- estado inicial de la solicitud
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la cancelación y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'cancelacion_id', v_cancelacion_id,
        'state', 'pendiente',
        'message', 'Cancelación de tarjeta registrada exitosamente'
    ) AS resultado;

END;

