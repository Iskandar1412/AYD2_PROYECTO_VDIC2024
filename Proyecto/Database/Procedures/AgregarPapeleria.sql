create
    definer = root@`%` procedure AgregarPapeleria(IN p_link_doc varchar(200), IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;
    DECLARE v_papeleria_id INT;

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

    -- Validar si el empleado existe
    SELECT COUNT(*) INTO v_empleado_existente
    FROM empleado
    WHERE cui = p_cui and vigencia = 'activo';

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Insertar la papelería
    INSERT INTO papeleria (
        link_doc,
        cui
    ) VALUES (
        p_link_doc,
        p_cui
    );

    -- Obtener el ID de la papelería recién creada
    SET v_papeleria_id = LAST_INSERT_ID();

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la papelería creada y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'papeleria_id', v_papeleria_id,
        'message', 'Papelería agregada exitosamente'
    ) AS resultado;

END;

