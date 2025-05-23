create
    definer = root@`%` procedure ActualizarDCliente(IN p_cuenta_id bigint, IN p_telefono bigint,
                                                    IN p_correo varchar(100), IN p_direccion text,
                                                    IN p_genero enum ('masculino', 'femenino'),
                                                    IN p_link_foto varchar(200), IN p_fecha_nac datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cui BIGINT;

    DECLARE v_telefono_actual BIGINT;
    DECLARE v_correo_actual VARCHAR(100);
    DECLARE v_direccion_actual TEXT;
    DECLARE v_genero_actual ENUM('masculino', 'femenino');
    DECLARE v_link_foto_actual VARCHAR(200);
    DECLARE v_fecha_nac_actual DATETIME;

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

    -- Obtener el CUI del cliente asociado a la cuenta
    SELECT cui INTO v_cui
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id;

    IF v_cui IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    -- Obtener los datos actuales del cliente
    SELECT telefono, correo, direccion, genero, link_foto, fecha_nac
    INTO v_telefono_actual, v_correo_actual, v_direccion_actual, v_genero_actual, v_link_foto_actual, v_fecha_nac_actual
    FROM cliente
    WHERE cui = v_cui;

    -- Actualizar los datos del cliente y registrar solo los cambios
    IF v_telefono_actual != p_telefono THEN
        UPDATE cliente SET telefono = p_telefono WHERE cui = v_cui;
        INSERT INTO cambio_cliente (cambio, fecha, cui)
        VALUES ('Teléfono actualizado', NOW(), v_cui);
    END IF;

    IF v_correo_actual != p_correo THEN
        UPDATE cliente SET correo = p_correo WHERE cui = v_cui;
        INSERT INTO cambio_cliente (cambio, fecha, cui)
        VALUES ('Correo actualizado', NOW(), v_cui);
    END IF;

    IF v_direccion_actual != p_direccion THEN
        UPDATE cliente SET direccion = p_direccion WHERE cui = v_cui;
        INSERT INTO cambio_cliente (cambio, fecha, cui)
        VALUES ('Dirección actualizada', NOW(), v_cui);
    END IF;

    IF v_genero_actual != p_genero THEN
        UPDATE cliente SET genero = p_genero WHERE cui = v_cui;
        INSERT INTO cambio_cliente (cambio, fecha, cui)
        VALUES ('Género actualizado', NOW(), v_cui);
    END IF;

    IF v_link_foto_actual != p_link_foto THEN
        UPDATE cliente SET link_foto = p_link_foto WHERE cui = v_cui;
        INSERT INTO cambio_cliente (cambio, fecha, cui)
        VALUES ('Foto actualizada', NOW(), v_cui);
    END IF;

    IF v_fecha_nac_actual != p_fecha_nac THEN
        UPDATE cliente SET fecha_nac = p_fecha_nac WHERE cui = v_cui;
        INSERT INTO cambio_cliente (cambio, fecha, cui)
        VALUES ('Fecha de nacimiento actualizada', NOW(), v_cui);
    END IF;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Datos del cliente actualizados exitosamente'
    ) AS resultado;

END;

