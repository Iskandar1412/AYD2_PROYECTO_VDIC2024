create
    definer = root@`%` procedure ActualizarDEmpleado(IN p_cui_or_user bigint, IN p_nombres varchar(50),
                                                     IN p_telefono bigint, IN p_correo varchar(100),
                                                     IN p_link_foto varchar(200),
                                                     IN p_genero enum ('masculino', 'femenino'),
                                                     IN p_estado_civil enum ('soltero', 'casado'))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cui BIGINT;

    DECLARE v_nombres_actual VARCHAR(50);
    DECLARE v_telefono_actual BIGINT;
    DECLARE v_correo_actual VARCHAR(100);
    DECLARE v_link_foto_actual VARCHAR(200);
    DECLARE v_genero_actual ENUM('masculino', 'femenino');
    DECLARE v_estado_civil_actual ENUM('soltero', 'casado');

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

    -- Determinar si es CUI o usuario y obtener el CUI
    SELECT cui INTO v_cui
    FROM empleado
    WHERE cui = p_cui_or_user OR usuario = p_cui_or_user and vigencia = 'activo';

    IF v_cui IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Empleado no encontrado';
    END IF;

    -- Obtener los datos actuales del empleado
    SELECT nombres, telefono, correo, link_foto, genero, estado_civil
    INTO v_nombres_actual, v_telefono_actual, v_correo_actual, v_link_foto_actual, v_genero_actual, v_estado_civil_actual
    FROM empleado
    WHERE cui = v_cui;

    -- Actualizar los datos del empleado y registrar solo los cambios
    IF v_nombres_actual != p_nombres THEN
        UPDATE empleado SET nombres = p_nombres WHERE cui = v_cui;
        INSERT INTO cambio_empleado (cambio, fecha, cui)
        VALUES ('Nombres actualizados', NOW(), v_cui);
    END IF;

    IF v_telefono_actual != p_telefono THEN
        UPDATE empleado SET telefono = p_telefono WHERE cui = v_cui;
        INSERT INTO cambio_empleado (cambio, fecha, cui)
        VALUES ('Teléfono actualizado', NOW(), v_cui);
    END IF;

    IF v_correo_actual != p_correo THEN
        UPDATE empleado SET correo = p_correo WHERE cui = v_cui;
        INSERT INTO cambio_empleado (cambio, fecha, cui)
        VALUES ('Correo actualizado', NOW(), v_cui);
    END IF;

    IF v_link_foto_actual != p_link_foto THEN
        UPDATE empleado SET link_foto = p_link_foto WHERE cui = v_cui;
        INSERT INTO cambio_empleado (cambio, fecha, cui)
        VALUES ('Foto actualizada', NOW(), v_cui);
    END IF;

    IF v_genero_actual != p_genero THEN
        UPDATE empleado SET genero = p_genero WHERE cui = v_cui;
        INSERT INTO cambio_empleado (cambio, fecha, cui)
        VALUES ('Género actualizado', NOW(), v_cui);
    END IF;

    IF v_estado_civil_actual != p_estado_civil THEN
        UPDATE empleado SET estado_civil = p_estado_civil WHERE cui = v_cui;
        INSERT INTO cambio_empleado (cambio, fecha, cui)
        VALUES ('Estado civil actualizado', NOW(), v_cui);
    END IF;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Datos del empleado actualizados exitosamente'
    ) AS resultado;

END;

