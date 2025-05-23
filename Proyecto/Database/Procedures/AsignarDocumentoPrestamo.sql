create
    definer = root@`%` procedure AsignarDocumentoPrestamo(IN p_link_pdf varchar(200), IN p_prestamo_id bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_prestamo_existente INT;

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

    -- Validar si el préstamo existe
    SELECT COUNT(*) INTO v_prestamo_existente
    FROM prestamo
    WHERE prestamo_id = p_prestamo_id;

    IF v_prestamo_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El préstamo no está registrado';
    END IF;

    -- Insertar el documento asociado al préstamo
    INSERT INTO documento (
        link_doc,
        prestamo_id
    ) VALUES (
        p_link_pdf,
        p_prestamo_id
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Documento asignado exitosamente al préstamo'
    ) AS resultado;

END;

