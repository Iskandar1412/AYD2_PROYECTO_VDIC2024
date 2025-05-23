CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ActualizarDCliente`(IN p_cuenta_id bigint, IN p_telefono bigint,
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ActualizarDEmpleado`(IN p_cui_or_user bigint, IN p_nombres varchar(50),
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`AgregarPapeleria`(IN p_link_doc varchar(200), IN p_cui bigint)
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`AsignacionRol`(IN p_empleado_id bigint,
                                               IN p_rol enum ('supervisor', 'administrador', 'cajero', 'atencion'))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;

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
    WHERE cui = p_empleado_id and vigencia = 'activo';

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Actualizar el rol del empleado
    UPDATE empleado
    SET rol = p_rol
    WHERE cui = p_empleado_id;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Rol asignado exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`AsignarDocumentoPrestamo`(IN p_link_pdf varchar(200), IN p_prestamo_id bigint)
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`BloquearTarjeta`(IN p_tarjeta_id bigint, IN p_motivo enum ('robo', 'perdida', 'fraude'),
                                                 IN p_fecha datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
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

    -- Actualizar la vigencia de la tarjeta
    UPDATE tarjeta
    SET vigencia = 'inactiva'
    WHERE tarjeta_id = p_tarjeta_id;

    -- Registrar el bloqueo de la tarjeta
    INSERT INTO bloqueo_tarjeta (
        fecha,
        motivo,
        tarjeta_id
    ) VALUES (
        p_fecha,
        p_motivo,
        p_tarjeta_id
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'inactiva',
        'message', 'Tarjeta bloqueada exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`BuscarCuentaCui`(IN p_input bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_nombres VARCHAR(50);
    DECLARE v_apellidos VARCHAR(50);
    DECLARE v_tipo ENUM('ahorro', 'monetaria');

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

    -- Buscar la cuenta y datos del cliente
    SELECT c.cuenta_id, cl.nombres, cl.apellidos, c.tipo
    INTO v_cuenta_id, v_nombres, v_apellidos, v_tipo
    FROM cuenta c
    JOIN cliente cl ON c.cui = cl.cui
    WHERE c.cuenta_id = p_input OR cl.cui = p_input and c.vigencia = 'activa';

    -- Si no se encuentra la cuenta, retornar error
    IF v_cuenta_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta o cliente no encontrado';
    END IF;

    -- Obtener las transacciones asociadas
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'trans_id', t.trans_id,
            'monto', t.monto,
            'tipo', t.tipo,
            'fecha', t.fecha
        )
    ) AS transacciones
    FROM transaccion t
    WHERE t.cuenta_id = v_cuenta_id
    INTO @transacciones;

    -- Retornar los datos y las transacciones
    SELECT JSON_OBJECT(
        'status', 'success',
        'cuenta_id', v_cuenta_id,
        'nombres', v_nombres,
        'apellidos', v_apellidos,
        'tipo', v_tipo,
        'transacciones', COALESCE(@transacciones, JSON_ARRAY()),
        'message', 'Consulta exitosa'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CambioPassWEmpleado`(IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cambio_existente INT;
    DECLARE v_password VARCHAR(200);

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

    -- Verificar si hay una solicitud pendiente de cambio de contraseña
    SELECT COUNT(*), password INTO v_cambio_existente, v_password
    FROM cambio_pass
    WHERE cui = p_cui AND estado = 'pendiente'
    group by password ;

    IF v_cambio_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay una solicitud pendiente de cambio de contraseña para este empleado';
    END IF;

    -- Actualizar la contraseña en la tabla empleado
    UPDATE empleado
    SET password = v_password
    WHERE cui = p_cui;

    -- Cambiar el estado de la solicitud de cambio de contraseña a 'realizado'
    UPDATE cambio_pass
    SET estado = 'realizado'
    WHERE cui = p_cui;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'realizado',
        'message', 'Contraseña actualizada exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CambioPassWEmpleadoSolicitud`(IN p_password varchar(200), IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;
    DECLARE v_password_hashed VARCHAR(200);

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
    WHERE cui = p_cui and vigencia='activo';

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Generar el hash SHA-256 de la nueva contraseña
    SET v_password_hashed = SHA2(p_password, 256);

    -- Insertar la solicitud de cambio de contraseña
    INSERT INTO cambio_pass (
        password,
        estado,
        cui
    ) VALUES (
        v_password_hashed,
        'pendiente', -- estado inicial de la solicitud
        p_cui
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'pendiente',
        'message', 'Solicitud de cambio de contraseña registrada exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CancelacionCuenta`(IN p_cuenta_id bigint, IN p_motivo varchar(100), IN p_fecha datetime,
                                                   IN p_tipo enum ('tarjeta', 'cuenta'))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cancelacion_id INT;
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

    -- Registrar la cancelación de la cuenta
    INSERT INTO cancelacion (
        motivo,
        fecha_solicitud,
        tipo,
        estado,
        cuenta_id
    ) VALUES (
        p_motivo,
        p_fecha,
        p_tipo,
        'pendiente',    -- estado inicial de la cancelación
        p_cuenta_id
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
        'message', 'Cancelación de cuenta registrada exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CancelacionTarjeta`(IN p_tarjeta_id bigint, IN p_motivo varchar(100),
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`Comentario`(IN p_detalle varchar(150), IN p_categoria varchar(50),
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CrearAdmin`(IN p_cui bigint, IN p_2fa varchar(200))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;
    DECLARE v_id_administrador INT;

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

    -- Verificar si el empleado existe
    SELECT COUNT(*) INTO v_empleado_existente
    FROM empleado
    WHERE cui = p_cui and vigencia = 'activo';

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Insertar en la tabla administrador
    INSERT INTO administrador (
        `2FA`,
        cui
    ) VALUES (
        p_2fa,
        p_cui
    );

    -- Obtener el ID del administrador recién creado
    SET v_id_administrador = LAST_INSERT_ID();

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'id_admin', v_id_administrador,
        'message', 'Administrador creado exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CrearCliente`(IN p_nombres varchar(50), IN p_apellidos varchar(50), IN p_cui bigint,
                                              IN p_telefono bigint, IN p_correo varchar(100), IN p_direccion text,
                                              IN p_genero enum ('masculino', 'femenino'), IN p_link_foto varchar(200),
                                              IN p_fecha_nac datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cui_existente INT;
    DECLARE v_telefono_existente INT;
    DECLARE v_correo_existente INT;

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

    -- Verificar si el CUI ya está registrado
    SELECT COUNT(*) INTO v_cui_existente
    FROM cliente
    WHERE cui = p_cui;

    IF v_cui_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El CUI ya está registrado';
    END IF;

    -- Verificar si el teléfono ya está registrado
    SELECT COUNT(*) INTO v_telefono_existente
    FROM cliente
    WHERE telefono = p_telefono;

    IF v_telefono_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El teléfono ya está registrado';
    END IF;

    -- Verificar si el correo ya está registrado
    SELECT COUNT(*) INTO v_correo_existente
    FROM cliente
    WHERE correo = p_correo;

    IF v_correo_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo ya está registrado';
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CrearCuenta`(IN p_saldo decimal(15, 2), IN p_tipo enum ('ahorro', 'monetaria'),
                                             IN p_fecha_apertura datetime, IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_cliente_existente INT;

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

    -- Validar si el cliente existe
    SELECT COUNT(*) INTO v_cliente_existente
    FROM cliente
    WHERE cui = p_cui;

    IF v_cliente_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no está registrado';
    END IF;
    
    -- Validar que el saldo inicial sea positivo
    IF p_saldo < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El saldo inicial debe ser positivo';
    END IF;

    -- Insertar la cuenta
    INSERT INTO cuenta (
        saldo,
        tipo,
        fecha_apertura,
        vigencia,
        cui
    ) VALUES (
        p_saldo,
        p_tipo,
        p_fecha_apertura,
        'activa',
        p_cui
    );

    -- Obtener el ID de la cuenta recién creada
    SET v_cuenta_id = LAST_INSERT_ID();
    
     -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible + p_saldo
    WHERE sucursal_id = 1;
    
    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la cuenta creada y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'cuenta_id', v_cuenta_id,
        'message', 'Cuenta creada exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CrearPregunta`(IN p_pregunta_encrip text, IN p_respuesta_encrip text,
                                               IN p_cuenta_id bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_pregunta_id BIGINT;
    DECLARE v_cuenta_existente INT;
	DECLARE v_pregunta_hash VARCHAR(200);
    DECLARE v_respuesta_hash VARCHAR(200);
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

    -- Validar si la cuenta existe
    SELECT COUNT(*) INTO v_cuenta_existente
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_cuenta_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no está registrada';
    END IF;

   	SET v_pregunta_hash = SHA2(p_pregunta_encrip, 256);
    SET v_respuesta_hash = SHA2(p_respuesta_encrip, 256);
    -- Insertar la pregunta de seguridad
    INSERT INTO pregunta_seguridad (
        pregunta_encrip,
        respuesta_encrip,
        cuenta_id
    ) VALUES (
        p_pregunta_encrip,
        p_respuesta_encrip,
        p_cuenta_id
    );

    -- Obtener el ID de la pregunta recién creada
    SET v_pregunta_id = LAST_INSERT_ID();

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la pregunta creada y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'pregunta_id', v_pregunta_id,
        'message', 'Pregunta de seguridad creada exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CrearSupervisor`(IN p_cui bigint, IN p_usuario varchar(50), IN p_password varchar(200),
                                                 IN p_password2 varchar(200))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;
    DECLARE v_password_hashed VARCHAR(200);

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
    
        IF v_error_message IS NULL THEN
            SET v_error_message = 'Error desconocido';
        END IF;
    
        SELECT JSON_OBJECT(
            'status', 'error',
            'message', CONCAT('Error SQL: ', v_error_message)
        ) AS resultado;
    
        ROLLBACK;
    END;

    -- Iniciar una transacción
    START TRANSACTION;

    -- Validar si el empleado existe
    SELECT COUNT(*) INTO v_empleado_existente
    FROM empleado
    WHERE cui = p_cui;

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_hashed = SHA2(p_password, 256);

    -- Insertar el registro en la tabla supervisor
    INSERT INTO supervisor (
        usuario,
        password,
        password2,
        cui
    ) VALUES (
        p_usuario,
        v_password_hashed,
        SHA2(p_password2, 256), -- Encriptar también la segunda contraseña
        p_cui
    );

    -- Actualizar el rol en la tabla empleado
    UPDATE empleado
    SET rol = 'supervisor'
    WHERE cui = p_cui;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'supervisor_id', LAST_INSERT_ID(),
        'message', 'Supervisor creado exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`CrearTarjeta`(IN p_cuenta_id bigint, IN p_tipo enum ('credito', 'debito'),
                                              IN p_limite decimal(15, 2), IN p_titular varchar(50), IN p_fecha datetime)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_tarjeta_id BIGINT;
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

    -- Validar que el límite sea mayor a 0
    IF p_limite <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El límite debe ser mayor a 0';
    END IF;

    -- Insertar la tarjeta con campos inicializados
    INSERT INTO tarjeta (
        tipo,
        limite,
        titular,
        monto,
        interes,
        tasa_interes,
        estado,
        vigencia,
        fecha_solicitud,
        cuenta_id
    ) VALUES (
        p_tipo,
        p_limite,
        p_titular,
        0.00,            -- monto inicializado a 0
        0.00,            -- interes inicializado a 0
        0.00,            -- tasa_interes inicializada a 0
        'pendiente',     -- estado inicial
        'activa',        -- vigencia inicial
        p_fecha,
        p_cuenta_id
    );

    -- Obtener el ID de la tarjeta recién creada
    SET v_tarjeta_id = LAST_INSERT_ID();

    -- Crear una solicitud para la tarjeta
    INSERT INTO solicitud (
        tarjeta_id,
        estado
    ) VALUES (
        v_tarjeta_id,
        'pendiente'      -- estado inicial de la solicitud
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la tarjeta creada y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'tarjeta_id', v_tarjeta_id,
        'state', 'pendiente',
        'message', 'Tarjeta creada exitosamente y solicitud registrada'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`DepositarDinero`(IN p_monto decimal(15, 2), IN p_fecha datetime, IN p_cuenta_id bigint,
                                                 IN p_deposito_id int, IN p_moneda_id int, IN p_encargado_cui bigint)
BEGIN
    DECLARE v_trans_id BIGINT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_moneda_tipo VARCHAR(25);
    DECLARE v_moneda_existente INT;
    DECLARE v_saldo_actual DECIMAL(15, 2);
    DECLARE v_encargado_existente INT;
    DECLARE v_cambio_quetzal DECIMAL(15, 2);
    DECLARE v_monto_en_quetzales DECIMAL(15, 2);

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

    -- Validar si la moneda existe y obtener el tipo y el cambio
    SELECT COUNT(*), tipo, cambio_quetzal INTO v_moneda_existente, v_moneda_tipo, v_cambio_quetzal
    FROM moneda
    WHERE moneda_id = p_moneda_id
    GROUP BY tipo, cambio_quetzal;

    IF v_moneda_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Moneda no encontrada';
    END IF;

    -- Calcular el monto en quetzales si es en dólares
    IF v_moneda_tipo = 'dolar' THEN
        SET v_monto_en_quetzales = p_monto * v_cambio_quetzal;
    ELSE
        SET v_monto_en_quetzales = p_monto;
    END IF;
    
    -- Validar si la cuenta existe y tiene saldo suficiente
    SELECT saldo INTO v_saldo_actual
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    -- Validar si el encargado existe
    SELECT COUNT(*) INTO v_encargado_existente
    FROM empleado
    WHERE cui = p_encargado_cui;

    IF v_encargado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El encargado no existe como empleado';
    END IF;

    -- Registrar el depósito
    INSERT INTO transaccion (
        monto,
        tipo,
        fecha,
        cuenta_id,
        deposito_id,
        moneda_id,
        empleado_cui
    ) VALUES (
        v_monto_en_quetzales,
        'deposito',
        p_fecha,
        p_cuenta_id,
        p_deposito_id,
        p_moneda_id,
        p_encargado_cui
    );

    -- Obtener el ID de la transacción recién creada
    SET v_trans_id = LAST_INSERT_ID();

    -- Actualizar el saldo de la cuenta
    UPDATE cuenta
    SET saldo = saldo + v_monto_en_quetzales
    WHERE cuenta_id = p_cuenta_id;

    -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible + v_monto_en_quetzales
    WHERE sucursal_id = 1;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la transacción y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'trans_id', v_trans_id,
        'message', 'Depósito realizado con éxito'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`EliminarEmpleado`(IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_despido_existente INT;
    DECLARE v_empleado_existente INT;

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

    -- Validar si el despido está registrado
    SELECT COUNT(*) INTO v_despido_existente
    FROM despido
    WHERE cui = p_cui AND estado = 'pendiente';

    IF v_despido_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay una solicitud pendiente para este empleado';
    END IF;

    -- Validar si el empleado existe
    SELECT COUNT(*) INTO v_empleado_existente
    FROM empleado
    WHERE cui = p_cui;

    IF v_empleado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no está registrado';
    END IF;

    -- Actualizar el estado del despido a 'realizado'
    UPDATE despido
    SET estado = 'realizado'
    WHERE cui = p_cui;

    -- Cambiar la vigencia del empleado a 'inactivo'
    UPDATE empleado
    SET vigencia = 'inactivo'
    WHERE cui = p_cui;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'realizado',
        'message', 'El empleado ha sido eliminado exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`EliminarEmpleadoSolicitud`(IN p_link_doc varchar(200), IN p_cui bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_empleado_existente INT;

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

    -- Insertar la solicitud de despido
    INSERT INTO despido (
        link_doc,
        estado,
        cui
    ) VALUES (
        p_link_doc,
        'pendiente', -- estado inicial de la solicitud
        p_cui
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'state', 'pendiente',
        'message', 'Solicitud de despido registrada exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerAdministradores`()
BEGIN
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

    -- Seleccionar los administradores y detalles de sus empleados
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'cui', a.cui,
        'usuario', e.usuario,
        'nombres', e.nombres,
        'apellidos', e.apellidos
    )) AS administradores
    FROM administrador a
    JOIN empleado e ON a.cui = e.cui
    WHERE e.vigencia = 'activo';

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerBackups`()
BEGIN
    DECLARE v_error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
        SELECT JSON_OBJECT(
            'status', 'error',
            'message', CONCAT('Ha ocurrido un error: ', v_error_message)
        ) AS resultado;
    END;

    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'id', id,
        'nombre_copia', nombre_copia,
        'fecha', fecha,
        'link_backup', link_backup
    )) AS resultado
    FROM backup;
    
END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerCambiosPass`()
BEGIN
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

    -- Seleccionar todos los cambios de contraseña pendientes
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'cambio_pass_id', cambio_pass_id,
        'cui', cui,
        'estado', estado
    )) AS resultado
    FROM cambio_pass
    WHERE estado = 'pendiente';

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerDespidos`()
BEGIN
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

    -- Seleccionar todos los despidos pendientes
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'despido_id', despido_id,
        'link_doc', link_doc,
        'estado', estado,
        'cui', cui
    )) AS resultado
    FROM despido
    WHERE estado = 'pendiente';

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerQuejas`()
BEGIN
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

    -- Seleccionar todas las quejas
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'comentario_id', comentario_id,
        'detalle', detalle,
        'categoria', categoria,
        'fecha', fecha,
        'puntuacion', puntuacion,
        'cui', cui
    )) AS resultado
    FROM comentario
    WHERE tipo = 'queja';

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerSatisfaccion`()
BEGIN
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

    -- Seleccionar todas las satisfacciones
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'comentario_id', comentario_id,
        'detalle', detalle,
        'categoria', categoria,
        'fecha', fecha,
        'puntuacion', puntuacion,
        'cui', cui
    )) AS resultado
    FROM comentario
    WHERE tipo = 'satisfaccion';

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerSolicitudEmpleados`()
BEGIN
    DECLARE v_error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;

        SELECT JSON_OBJECT(
            'status', 'error',
            'message', CONCAT('Ha ocurrido un error: ', v_error_message)
        ) AS resultado;
    END;

    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'usuario', e.usuario,
        'nombres', e.nombres,
        'apellidos', e.apellidos,
        'edad', TIMESTAMPDIFF(YEAR, e.fecha_nac, CURDATE()),
        'cui', e.cui,
        'correo', e.correo,
        'en_cambio_password', IF(cps.cui IS NOT NULL, TRUE, FALSE),
        'en_eliminar_solicitud', IF(els.cui IS NOT NULL, TRUE, FALSE)
    )) AS empleados
    FROM empleado e
    LEFT JOIN CambioPassWEmpleadoSolicitud cps ON e.cui = cps.cui
    LEFT JOIN EliminarEmpleadoSolicitud els ON e.cui = els.cui 
    WHERE e.vigencia = 'activo'
    AND e.rol NOT IN ('supervisor', 'administrador');
    
END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerSolicitudes`()
BEGIN
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

    -- Seleccionar todas las solicitudes pendientes
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'solicitud_id', solicitud_id,
        'prestamo_id', prestamo_id,
        'tarjeta_id', tarjeta_id,
        'cancelacion_id', cancelacion_id,
        'estado', estado
    )) AS resultado
    FROM solicitud
    WHERE estado = 'pendiente';

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`ExtraerTodosLosEmpleados`()
BEGIN
    DECLARE v_error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;

        SELECT JSON_OBJECT(
            'status', 'error',
            'message', CONCAT('Ha ocurrido un error: ', v_error_message)
        ) AS resultado;
    END;


    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'usuario', e.usuario,
        'nombres', e.nombres,
        'apellidos', e.apellidos,
        'edad', TIMESTAMPDIFF(YEAR, e.fecha_nac, CURDATE()),
        'dpi', e.cui,
        'telefono', e.telefono,
        'correo', e.correo,
        'rol', e.rol,
        'id_administrador', a.id_administrador
    )) AS empleados
    FROM empleado e
    LEFT JOIN administrador a ON e.cui = a.cui 
    WHERE e.vigencia = 'activo'
    AND e.rol != 'supervisor';

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`GenerarComprobante`(IN p_trans_id bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_tipo VARCHAR(25);
    DECLARE v_fecha DATETIME;
    DECLARE v_monto DECIMAL(15, 2);
    DECLARE v_tipomoneda VARCHAR(25);
    DECLARE v_nombre_encargado VARCHAR(100);

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

    -- Obtener los datos de la transacción
    SELECT t.cuenta_id, t.tipo, t.fecha, t.monto, m.tipo, CONCAT(e.nombres, ' ', e.apellidos)
    INTO v_cuenta_id, v_tipo, v_fecha, v_monto, v_tipomoneda, v_nombre_encargado
    FROM transaccion t
    JOIN moneda m ON t.moneda_id = m.moneda_id
    JOIN empleado e ON t.empleado_cui = e.cui
    WHERE t.trans_id = p_trans_id;

    -- Validar si la transacción existe
    IF v_cuenta_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transacción no encontrada';
    END IF;

    -- Retornar los datos del comprobante
    SELECT JSON_OBJECT(
        'status', 'success',
        'cuenta_id', v_cuenta_id,
        'tipo', v_tipo,
        'fecha', v_fecha,
        'monto', v_monto,
        'tipomoneda', v_tipomoneda,
        'nombre_encargado', v_nombre_encargado,
        'message', 'Comprobante generado exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`GestionInventario`()
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_dinero_total DECIMAL(15, 2);
    DECLARE v_dinero_quetzales DECIMAL(15, 2);
    DECLARE v_dinero_dolares DECIMAL(15, 2);
    DECLARE v_transacciones JSON;
    DECLARE v_suma_dolares DECIMAL(15, 2);
    DECLARE v_cambio_quetzal DECIMAL(15, 2);

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


    SET v_dinero_quetzales = 0;
    SET v_dinero_dolares = 0;

    -- Obtener el dinero disponible total
    SELECT dinero_disponible INTO v_dinero_total FROM sucursal WHERE sucursal_id = 1;

    -- Obtener la suma en quetzales de las transacciones en dólares
    SELECT SUM(monto) INTO v_suma_dolares
    FROM transaccion t
    JOIN moneda m ON t.moneda_id = m.moneda_id
    WHERE m.tipo = 'dolar';

    IF v_suma_dolares IS NULL THEN
        SET v_suma_dolares = 0;
    end if;

    -- Calcular el dinero en quetzales
    SET v_dinero_quetzales = v_dinero_total - v_suma_dolares;

    -- Obtener el cambio del dólar a quetzal
    SELECT cambio_quetzal INTO v_cambio_quetzal FROM moneda WHERE tipo = 'dolar';

    -- Calcular el dinero en dólares
    SET v_dinero_dolares = v_suma_dolares / v_cambio_quetzal;

    -- Obtener el arreglo de transacciones
    SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'transaccion_id', trans_id,
        'monto', monto,
        'tipo', tipo,
        'fecha', fecha,
        'moneda', (SELECT tipo FROM moneda WHERE moneda_id = t.moneda_id),
        'cuenta_id', cuenta_id
    )) INTO v_transacciones
    FROM transaccion t;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar los datos del inventario
    SELECT JSON_OBJECT(
        'status', 'success',
        'dinero_total', v_dinero_total,
        'dinero_quetzales', v_dinero_quetzales,
        'dinero_dolares', v_dinero_dolares,
        'transacciones', v_transacciones
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`InsertarBackup`(
    IN p_nombre_copia VARCHAR(100),
    IN p_link_backup VARCHAR(250)
)
BEGIN
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

    -- Insertar el nuevo registro en la tabla de backups
    INSERT INTO backup (nombre_copia, link_backup)
    VALUES (p_nombre_copia, p_link_backup);

    -- Retornar un mensaje de éxito en formato JSON
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Backup insertado correctamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`Login`(IN p_input varchar(100), IN p_password varchar(200))
BEGIN
    DECLARE v_cui BIGINT;
    DECLARE v_usuario VARCHAR(50);
    DECLARE v_password_hash VARCHAR(200);
    DECLARE v_password_input_hash VARCHAR(200);
    DECLARE v_rol ENUM('supervisor', 'administrador', 'cajero', 'atencion');
    DECLARE v_vigencia ENUM('activo', 'inactivo');
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_nombres VARCHAR(50);
    DECLARE v_apellidos VARCHAR(50);

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

    -- Verificar si el usuario o correo existe y obtener sus datos
    SELECT cui, usuario, password, rol, vigencia,nombres,apellidos
    INTO v_cui, v_usuario, v_password_hash, v_rol, v_vigencia,v_nombres,v_apellidos
    FROM empleado
    WHERE (usuario = p_input OR correo = p_input);

    -- Si no se encuentra el usuario/correo, retornar error
    IF v_password_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario o correo no encontrado';
    END IF;

    -- Verificar si el empleado está activo
    IF v_vigencia = 'inactivo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta del empleado está inactiva';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_input_hash = SHA2(p_password, 256);

    -- Verificar si la contraseña coincide con la almacenada (compara los hashes)
    IF v_password_hash != v_password_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
    END IF;

    -- Retornar el cui, usuario y rol si la autenticación es exitosa
    SELECT JSON_OBJECT(
        'status', 'success',
        'cui', v_cui,
        'usuario', v_usuario,
        'rol', v_rol,
        'nombres', v_nombres,
        'apellidos', v_apellidos,
        'message', 'Autenticación exitosa'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`LoginAdm2fa`(
    IN p_id_admin INT, 
    IN p_2fa VARCHAR(200),
    IN p_cui BIGINT
)
BEGIN
    DECLARE v_2fa_stored VARCHAR(200);
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_usuario VARCHAR(50);
    DECLARE v_telefono BIGINT;
    DECLARE v_rol ENUM('supervisor','administrador','cajero','atencion','pendiente');
    DECLARE v_nombres VARCHAR(50);
    DECLARE v_apellidos VARCHAR(50);
    DECLARE v_correo VARCHAR(100);

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

    -- Obtener información del empleado usando el CUI
    SELECT usuario, telefono, rol, nombres, apellidos, correo
    INTO v_usuario, v_telefono, v_rol, v_nombres, v_apellidos, v_correo
    FROM empleado
    WHERE cui = p_cui;

    -- Si no se encuentra el empleado, retornar error
    IF v_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Empleado no encontrado';
    END IF;

    -- Retornar información del empleado en formato JSON
    SELECT JSON_OBJECT(
        'status', 'success',
        'usuario', v_usuario,
        'telefono', v_telefono,
        'rol', v_rol,
        'nombres', v_nombres,
        'apellidos', v_apellidos,
        'correo', v_correo,
        'cui', p_cui
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`LoginAdmin`(
    IN p_input VARCHAR(100), 
    IN p_password VARCHAR(200)
)
BEGIN
    DECLARE v_cui BIGINT;
    DECLARE v_usuario VARCHAR(50);
    DECLARE v_password_hash VARCHAR(200);
    DECLARE v_password_input_hash VARCHAR(200);
    DECLARE v_id_administrador INT;
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

    -- Verificar si el usuario o CUI existe y obtener sus datos
    SELECT e.cui, e.usuario, e.password, a.id_administrador
    INTO v_cui, v_usuario, v_password_hash, v_id_administrador
    FROM empleado e
    JOIN administrador a ON e.cui = a.cui
    WHERE (e.usuario = p_input OR e.correo = p_input) 
    AND e.vigencia = 'activo';

    -- Si no se encuentra el usuario/cui, retornar error
    IF v_password_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario o CUI no encontrado';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_input_hash = SHA2(p_password, 256);

    -- Verificar si la contraseña coincide con la almacenada (compara los hashes)
    IF v_password_hash != v_password_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
    END IF;

    -- Retornar el ID del administrador, CUI y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'id_admin', v_id_administrador,
        'cui', v_cui,  -- Agregar el cui al JSON de respuesta
        'message', 'Autenticación exitosa'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`LoginSupe2pass`(IN p_supervisor_id INT, IN p_password2 VARCHAR(200))
BEGIN
    DECLARE v_password2_hash VARCHAR(200);
    DECLARE v_password2_input_hash VARCHAR(200);
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_cui BIGINT;

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

    -- Verificar si el supervisor existe y obtener la segunda contraseña y CUI
    SELECT password2, cui
    INTO v_password2_hash, v_cui
    FROM supervisor
    WHERE supervisor_id = p_supervisor_id;

    -- Si no se encuentra el supervisor, retornar error
    IF v_password2_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Supervisor no encontrado';
    END IF;

    -- Generar el hash SHA-256 de la segunda contraseña proporcionada
    SET v_password2_input_hash = SHA2(p_password2, 256);

    -- Verificar si la segunda contraseña coincide con la almacenada (compara los hashes)
    IF v_password2_hash != v_password2_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Segunda contraseña incorrecta';
    END IF;

    -- Retornar los datos del empleado en formato JSON
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Segunda contraseña autenticada exitosamente',
        'empleado', JSON_OBJECT(
            'cui', e.cui,
            'usuario', e.usuario,
            'nombres', e.nombres,
            'apellidos', e.apellidos,
            'telefono', e.telefono,
            'correo', e.correo,
            'rol', e.rol
        )
    ) AS resultado
    FROM empleado e
    WHERE e.cui = v_cui;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`LoginSupervisor`(IN p_usuario varchar(50), IN p_password varchar(200))
BEGIN
    DECLARE v_supervisor_id INT;
    DECLARE v_password_hash VARCHAR(200);
    DECLARE v_password_input_hash VARCHAR(200);
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

    -- Verificar si el usuario existe y obtener sus datos
    SELECT supervisor_id, password
    INTO v_supervisor_id, v_password_hash
    FROM supervisor
    WHERE usuario = p_usuario;

    -- Si no se encuentra el usuario, retornar error
    IF v_password_hash IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario no encontrado';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_input_hash = SHA2(p_password, 256);

    -- Verificar si la contraseña coincide con la almacenada (compara los hashes)
    IF v_password_hash != v_password_input_hash THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Contraseña incorrecta';
    END IF;

    -- Retornar el supervisor_id si la autenticación es exitosa
    SELECT JSON_OBJECT(
        'status', 'success',
        'supervisor_id', v_supervisor_id,
        'message', 'Autenticación exitosa'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`Monitoreo`()
BEGIN
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

    -- Obtener los contadores
    SELECT JSON_OBJECT(
        'retiros', (SELECT COUNT(*) FROM transaccion WHERE tipo = 'retiro'),
        'solicitud_prestamos', (SELECT COUNT(*) FROM solicitud WHERE prestamo_id IS NOT NULL),
        'bloqueos', (SELECT COUNT(*) FROM bloqueo_tarjeta),
        'solicitud_tarjetas', (SELECT COUNT(*) FROM solicitud WHERE tarjeta_id IS NOT NULL),
        'despidos', (SELECT COUNT(*) FROM despido),
        'cambios_contrasena', (SELECT COUNT(*) FROM cambio_pass WHERE estado = 'pendiente')
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`MostrarSaldo`(IN p_cuenta_id bigint)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_saldo DECIMAL(15, 2);
    DECLARE v_fecha_ultima_trans DATETIME;

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

    -- Validar si la cuenta existe y obtener el saldo
    SELECT saldo INTO v_saldo
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    -- Obtener la fecha de la última transacción
    SELECT MAX(fecha) INTO v_fecha_ultima_trans
    FROM transaccion
    WHERE cuenta_id = p_cuenta_id;

    -- Retornar el saldo y la fecha de la última transacción
    SELECT JSON_OBJECT(
        'status', 'success',
        'saldo', v_saldo,
        'ultima_transaccion', COALESCE(v_fecha_ultima_trans, 'No hay transacciones'),
        'message', 'Consulta exitosa'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`PagarPrestamo`(IN p_monto decimal(15, 2), IN p_fecha datetime, IN p_cuenta_id bigint,
                                               IN p_prestamo_id bigint, IN p_moneda_id int, IN p_encargado_cui bigint)
BEGIN
    DECLARE v_trans_id BIGINT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_prestamo_existente INT;
    DECLARE v_moneda_existente INT;
    DECLARE v_encargado_existente INT;
    DECLARE v_saldo_actual DECIMAL(15, 2);
    DECLARE v_monto_restante DECIMAL(15, 2);
    DECLARE v_cambio_quetzal DECIMAL(15, 2);
    DECLARE v_monto_en_quetzales DECIMAL(15, 2);
    DECLARE v_moneda_tipo VARCHAR(25);

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

    -- Validar si la moneda existe y obtener el tipo y el cambio
    SELECT COUNT(*), tipo, cambio_quetzal INTO v_moneda_existente, v_moneda_tipo, v_cambio_quetzal
    FROM moneda
    WHERE moneda_id = p_moneda_id
    GROUP BY tipo, cambio_quetzal ;

    IF v_moneda_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Moneda no encontrada';
    END IF;

    -- Calcular el monto en quetzales si es en dólares
    IF v_moneda_tipo = 'dolar' THEN
        SET v_monto_en_quetzales = p_monto * v_cambio_quetzal;
    ELSE
        SET v_monto_en_quetzales = p_monto;
    END IF;

    -- Validar si la cuenta tiene saldo suficiente
    SELECT saldo INTO v_saldo_actual
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    IF v_saldo_actual < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;

    -- Validar si el préstamo existe y obtener el monto restante
    SELECT COUNT(*), saldo INTO v_prestamo_existente, v_monto_restante
    FROM prestamo
    WHERE prestamo_id = p_prestamo_id
    GROUP BY saldo ;

    IF v_prestamo_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Préstamo no encontrado';
    END IF;

    IF v_monto_restante < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto excede el saldo del préstamo';
    END IF;

    -- Validar si el encargado existe
    SELECT COUNT(*) INTO v_encargado_existente
    FROM empleado
    WHERE cui = p_encargado_cui;

    IF v_encargado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El encargado no existe como empleado';
    END IF;

    -- Registrar el pago del préstamo
    INSERT INTO transaccion (
        monto,
        tipo,
        fecha,
        cuenta_id,
        prestamo_id,
        moneda_id,
        empleado_cui
    ) VALUES (
        v_monto_en_quetzales,
        'prestamo',
        p_fecha,
        p_cuenta_id,
        p_prestamo_id,
        p_moneda_id,
        p_encargado_cui
    );

    -- Obtener el ID de la transacción recién creada
    SET v_trans_id = LAST_INSERT_ID();

    -- Actualizar el saldo de la cuenta
    UPDATE cuenta
    SET saldo = saldo - v_monto_en_quetzales
    WHERE cuenta_id = p_cuenta_id;

    -- Actualizar el monto restante del préstamo
    UPDATE prestamo
    SET saldo = saldo - v_monto_en_quetzales
    WHERE prestamo_id = p_prestamo_id;
    
    -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible + v_monto_en_quetzales
    WHERE sucursal_id = 1;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la transacción y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'trans_id', v_trans_id,
        'message', 'Pago realizado con éxito'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`PagarServicio`(IN p_monto decimal(15, 2), IN p_fecha datetime, IN p_cuenta_id bigint,
                                               IN p_servicio_id int, IN p_moneda_id int, IN p_encargado_cui bigint)
BEGIN
    DECLARE v_trans_id BIGINT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_servicio_existente INT;
    DECLARE v_moneda_existente INT;
    DECLARE v_encargado_existente INT;
    DECLARE v_saldo_actual DECIMAL(15, 2);
    DECLARE v_cambio_quetzal DECIMAL(15, 2);
    DECLARE v_monto_en_quetzales DECIMAL(15, 2);
    DECLARE v_moneda_tipo VARCHAR(25);

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
    
        IF v_error_message IS NULL THEN
            SET v_error_message = 'Error desconocido';
        END IF;
    
        SELECT JSON_OBJECT(
            'status', 'error',
            'message', CONCAT('Error SQL: ', v_error_message)
        ) AS resultado;
    
        ROLLBACK;
    END;


    -- Iniciar una transacción
    START TRANSACTION;

    -- Validar si la moneda existe y obtener el tipo y el cambio
    SELECT COUNT(*), tipo, cambio_quetzal INTO v_moneda_existente, v_moneda_tipo, v_cambio_quetzal
    FROM moneda
    WHERE moneda_id = p_moneda_id
    GROUP BY tipo, cambio_quetzal;

    IF v_moneda_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Moneda no encontrada';
    END IF;

    -- Calcular el monto en quetzales si es en dólares
    IF v_moneda_tipo = 'dolar' THEN
        SET v_monto_en_quetzales = p_monto * v_cambio_quetzal;
    ELSE
        SET v_monto_en_quetzales = p_monto;
    END IF;

    -- Validar si la cuenta tiene saldo suficiente
    SELECT saldo INTO v_saldo_actual
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    IF v_saldo_actual < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;

    -- Validar si el servicio existe
    SELECT COUNT(*) INTO v_servicio_existente
    FROM servicio
    WHERE servicio_id = p_servicio_id;

    IF v_servicio_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Servicio no encontrado';
    END IF;

    -- Validar si el encargado existe
    SELECT COUNT(*) INTO v_encargado_existente
    FROM empleado
    WHERE cui = p_encargado_cui;

    IF v_encargado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El encargado no existe como empleado';
    END IF;

    -- Registrar el pago del servicio
    INSERT INTO transaccion (
        monto,
        tipo,
        fecha,
        cuenta_id,
        servicio_id,
        moneda_id,
        empleado_cui
    ) VALUES (
        v_monto_en_quetzales,
        'servicio',
        p_fecha,
        p_cuenta_id,
        p_servicio_id,
        p_moneda_id,
        p_encargado_cui
    );

    -- Obtener el ID de la transacción recién creada
    SET v_trans_id = LAST_INSERT_ID();

    -- Actualizar el saldo de la cuenta
    UPDATE cuenta
    SET saldo = saldo - v_monto_en_quetzales
    WHERE cuenta_id = p_cuenta_id;

     -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible + v_monto_en_quetzales
    WHERE sucursal_id = 1;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la transacción y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'trans_id', v_trans_id,
        'message', 'Pago realizado con éxito'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`PagarTarjeta`(IN p_monto decimal(15, 2), IN p_fecha datetime, IN p_cuenta_id bigint,
                                              IN p_tarjeta_id bigint, IN p_moneda_id int, IN p_encargado_cui bigint)
BEGIN
    DECLARE v_trans_id BIGINT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_moneda_tipo VARCHAR(25);
    DECLARE v_saldo_actual DECIMAL(15, 2);
    DECLARE v_tarjeta_existente INT;
    DECLARE v_moneda_existente INT;
    DECLARE v_encargado_existente INT;
    DECLARE v_cambio_quetzal DECIMAL(15, 2);
    DECLARE v_monto_en_quetzales DECIMAL(15, 2);

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
        SET MESSAGE_TEXT = 'Tarjeta no encontrada';
    END IF;

    -- Validar si la moneda existe y obtener el tipo y el cambio
    SELECT COUNT(*), tipo, cambio_quetzal INTO v_moneda_existente, v_moneda_tipo, v_cambio_quetzal
    FROM moneda
    WHERE moneda_id = p_moneda_id
    GROUP BY tipo, cambio_quetzal;

    IF v_moneda_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Moneda no encontrada';
    END IF;

    -- Calcular el monto en quetzales si es en dólares
    IF v_moneda_tipo = 'dolar' THEN
        SET v_monto_en_quetzales = p_monto * v_cambio_quetzal;
    ELSE
        SET v_monto_en_quetzales = p_monto;
    END IF;

    -- Validar si la cuenta existe y tiene saldo suficiente
    SELECT saldo INTO v_saldo_actual
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    IF v_saldo_actual < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;

    -- Validar si el encargado existe
    SELECT COUNT(*) INTO v_encargado_existente
    FROM empleado
    WHERE cui = p_encargado_cui;

    IF v_encargado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El encargado no existe como empleado';
    END IF;

    -- Registrar el pago de la tarjeta
    INSERT INTO transaccion (
        monto,
        tipo,
        fecha,
        cuenta_id,
        tarjeta_id,
        moneda_id,
        empleado_cui
    ) VALUES (
        v_monto_en_quetzales,
        'pago_tarjeta',
        p_fecha,
        p_cuenta_id,
        p_tarjeta_id,
        p_moneda_id,
        p_encargado_cui
    );

    -- Obtener el ID de la transacción recién creada
    SET v_trans_id = LAST_INSERT_ID();

    -- Actualizar el saldo de la cuenta
    UPDATE cuenta
    SET saldo = saldo - v_monto_en_quetzales
    WHERE cuenta_id = p_cuenta_id;

    -- Actualizar el monto e interés de la tarjeta a 0
    UPDATE tarjeta
    SET monto = 0, interes = 0
    WHERE tarjeta_id = p_tarjeta_id;
    
     -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible + v_monto_en_quetzales
    WHERE sucursal_id = 1;


    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la transacción y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'trans_id', v_trans_id,
        'message', 'Pago de tarjeta realizado con éxito'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`PermitirCuentaDolar`(IN p_cuenta_id bigint, IN p_fecha datetime)
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

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`RegistrarEmpleado`(
    IN p_cui bigint, 
    IN p_nombres varchar(50),
    IN p_apellidos varchar(50), 
    IN p_telefono bigint,
    IN p_fecha_nac datetime, 
    IN p_correo varchar(100),
    IN p_usuario varchar(50), 
    IN p_password varchar(200),
    IN p_link_foto varchar(200),
    IN p_link_firma varchar(200),
    IN p_genero enum ('masculino', 'femenino'),
    IN p_estado_civil enum ('soltero', 'casado'),
    IN p_link_papeleria varchar(200)  -- Ahora es el último parámetro
)
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_sucursal_existente INT;
    DECLARE v_usuario_existente INT;
    DECLARE v_telefono_existente INT;
    DECLARE v_correo_existente INT;
    DECLARE v_password_hashed VARCHAR(200);

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

    -- Validar si la sucursal existe
    SELECT COUNT(*) INTO v_sucursal_existente
    FROM sucursal
    WHERE sucursal_id = 1;

    IF v_sucursal_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La sucursal no está registrada';
    END IF;

    -- Verificar si el usuario ya existe
    SELECT COUNT(*) INTO v_usuario_existente
    FROM empleado
    WHERE usuario = p_usuario;

    IF v_usuario_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario ya está registrado';
    END IF;

    -- Verificar si el teléfono ya existe
    SELECT COUNT(*) INTO v_telefono_existente
    FROM empleado
    WHERE telefono = p_telefono;

    IF v_telefono_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El teléfono ya está registrado';
    END IF;

    -- Verificar si el correo ya existe
    SELECT COUNT(*) INTO v_correo_existente
    FROM empleado
    WHERE correo = p_correo;

    IF v_correo_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo ya está registrado';
    END IF;

    -- Generar el hash SHA-256 de la contraseña proporcionada
    SET v_password_hashed = SHA2(p_password, 256);

    -- Registrar el empleado
    INSERT INTO empleado (
        cui,
        usuario,
        password,
        nombres,
        apellidos,
        telefono,
        correo,
        link_foto,
        link_firma,
        genero,
        estado_civil,
        fecha_nac,
        vigencia,
        rol,
        sucursal_id,
        link_papeleria  -- Ahora el último campo en la tabla
    ) VALUES (
        p_cui,
        p_usuario,
        v_password_hashed,
        p_nombres,
        p_apellidos,
        p_telefono,
        p_correo,
        p_link_foto,
        p_link_firma,
        p_genero,
        p_estado_civil,
        p_fecha_nac,
        'activo',
        'pendiente', -- rol inicial
        1,
        p_link_papeleria  -- Valor de link_papeleria que se pasa como parámetro
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', 'Empleado registrado exitosamente'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`RetirarDinero`(IN p_monto decimal(15, 2), IN p_fecha datetime, IN p_cuenta_id bigint,
                                               IN p_retiro_id int, IN p_moneda_id int, IN p_encargado_id bigint)
BEGIN
    DECLARE v_trans_id BIGINT;
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_moneda_tipo VARCHAR(25);
    DECLARE v_saldo_actual DECIMAL(15, 2);
    DECLARE v_saldo_sucursal DECIMAL(15, 2);
    DECLARE v_dolar_cuenta_id BIGINT;
    DECLARE v_moneda_existente INT;
    DECLARE v_encargado_existente INT;
    DECLARE v_cambio_quetzal DECIMAL(15, 2);
    DECLARE v_monto_en_quetzales DECIMAL(15, 2);    
    DECLARE v_limite DECIMAL(15, 2);

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

    -- Validar si la moneda existe y obtener el tipo y el cambio
    SELECT COUNT(*), tipo, cambio_quetzal INTO v_moneda_existente, v_moneda_tipo, v_cambio_quetzal
    FROM moneda
    WHERE moneda_id = p_moneda_id
    group by tipo, cambio_quetzal ;

    IF v_moneda_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Moneda no encontrada';
    END IF;

    -- Calcular el monto en quetzales si es en dólares
    IF v_moneda_tipo = 'dolar' THEN
        SET v_monto_en_quetzales = p_monto * v_cambio_quetzal;

        -- Verificar si la cuenta tiene una cuenta en dólares asociada
        SELECT cuenta_dolar_id INTO v_dolar_cuenta_id
        FROM cuenta_dolar
        WHERE cuenta_id = p_cuenta_id;

        IF v_dolar_cuenta_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cuenta no está asociada a una cuenta en dólares';
        END IF;

        -- Verificar que no supere el límite en quetzales equivalentes
        IF v_monto_en_quetzales > 10000 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se pueden retirar más de 10000 quetzales en dólares';
        END IF;
    ELSE
        SET v_monto_en_quetzales = p_monto;
    END IF;

     -- Verificar el límite del retiro asociado al retiro_id
    SELECT limite INTO v_limite
    FROM retiro
    WHERE retiro_id = p_retiro_id;

    IF v_monto_en_quetzales > v_limite THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto excede el límite permitido para este retiro';
    END IF;

    -- Validar si la cuenta existe y tiene saldo suficiente
    SELECT saldo INTO v_saldo_actual
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id and vigencia = 'activa';

    IF v_saldo_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cuenta no encontrada';
    END IF;

    IF v_saldo_actual < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;

    -- Validar si hay suficiente dinero en la sucursal
    SELECT dinero_disponible INTO v_saldo_sucursal
    FROM sucursal
    WHERE sucursal_id = 1;

    IF v_saldo_sucursal IS NULL OR v_saldo_sucursal < v_monto_en_quetzales THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente en la sucursal';
    END IF;

    -- Validar si el encargado existe
    SELECT COUNT(*) INTO v_encargado_existente
    FROM empleado
    WHERE cui = p_encargado_id;

    IF v_encargado_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El encargado no existe como empleado';
    END IF;

    -- Registrar el retiro
    INSERT INTO transaccion (
        monto,
        tipo,
        fecha,
        cuenta_id,
        retiro_id,
        moneda_id,
        empleado_cui
    ) VALUES (
        v_monto_en_quetzales,
        'retiro',
        p_fecha,
        p_cuenta_id,
        p_retiro_id,
        p_moneda_id,
        p_encargado_id
    );

    -- Obtener el ID de la transacción recién creada
    SET v_trans_id = LAST_INSERT_ID();

    -- Actualizar el saldo de la cuenta
    UPDATE cuenta
    SET saldo = saldo - v_monto_en_quetzales
    WHERE cuenta_id = p_cuenta_id;

    -- Actualizar el saldo de la sucursal
    UPDATE sucursal
    SET dinero_disponible = dinero_disponible - v_monto_en_quetzales
    WHERE sucursal_id = 1;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID de la transacción y mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'trans_id', v_trans_id,
        'message', 'Retiro realizado con éxito'
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`RevisarCancelacion`(IN p_cancelacion_id int, IN p_estado enum ('aceptado', 'rechazado'),
                                                    IN p_justificacion varchar(255))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_solicitud_existente INT;
    DECLARE v_tipo ENUM('tarjeta', 'cuenta');
    DECLARE v_cuenta_id BIGINT;
    DECLARE v_tarjeta_id BIGINT;
    DECLARE v_monto_tarjeta DECIMAL(15, 2);
    DECLARE v_saldo_prestamo DECIMAL(15, 2);

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

    -- Verificar si la solicitud de la cancelación existe
    SELECT COUNT(*), tipo, cuenta_id, tarjeta_id
    INTO v_solicitud_existente, v_tipo, v_cuenta_id, v_tarjeta_id
    FROM solicitud
    JOIN cancelacion ON solicitud.cancelacion_id = cancelacion.cancelacion_id
    WHERE solicitud.cancelacion_id = p_cancelacion_id
    group by tipo, cuenta_id, tarjeta_id ;

    IF v_solicitud_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La solicitud de cancelación no existe';
    END IF;

    -- Si la cancelación es aceptada, realizar validaciones adicionales
    IF p_estado = 'aceptado' THEN
        IF v_tipo = 'tarjeta' THEN
            -- Verificar que la tarjeta no tenga monto pendiente
            SELECT monto INTO v_monto_tarjeta
            FROM tarjeta
            WHERE tarjeta_id = v_tarjeta_id;

            IF v_monto_tarjeta > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La tarjeta tiene un monto pendiente';
            END IF;

            -- Cambiar la vigencia de la tarjeta a "inactiva"
            UPDATE tarjeta
            SET vigencia = 'inactiva'
            WHERE tarjeta_id = v_tarjeta_id;

        ELSEIF v_tipo = 'cuenta' THEN
            -- Verificar que la cuenta no tenga préstamos pendientes
            SELECT SUM(saldo) INTO v_saldo_prestamo
            FROM prestamo
            WHERE cuenta_id = v_cuenta_id;

            IF v_saldo_prestamo > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La cuenta tiene préstamos pendientes';
            END IF;

            -- Cambiar la vigencia de la cuenta a "inactiva"
            UPDATE cuenta
            SET vigencia = 'inactiva'
            WHERE cuenta_id = v_cuenta_id;
        END IF;
    END IF;

    -- Actualizar el estado de la solicitud
    UPDATE solicitud
    SET estado = p_estado, justificacion = p_justificacion
    WHERE cancelacion_id = p_cancelacion_id;

    -- Actualizar el estado de la cancelación
    UPDATE cancelacion
    SET estado = p_estado
    WHERE cancelacion_id = p_cancelacion_id;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', CONCAT('Cancelación ', p_estado, ' exitosamente')
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`RevisarPrestamo`(IN p_prestamo_id bigint, IN p_estado enum ('aceptado', 'rechazado'),
                                                 IN p_justificacion varchar(255))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_solicitud_existente INT;

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

    -- Verificar si la solicitud del préstamo existe
    SELECT COUNT(*) INTO v_solicitud_existente
    FROM solicitud
    WHERE prestamo_id = p_prestamo_id;

    IF v_solicitud_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La solicitud del préstamo no existe';
    END IF;

    -- Actualizar el estado de la solicitud
    UPDATE solicitud
    SET estado = p_estado, justificacion = p_justificacion
    WHERE prestamo_id = p_prestamo_id;

    -- Actualizar el estado del préstamo
    UPDATE prestamo
    SET estado = p_estado
    WHERE prestamo_id = p_prestamo_id;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', CONCAT('Préstamo ', p_estado, ' exitosamente')
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`RevisarTarjeta`(IN p_tarjeta_id bigint, IN p_estado enum ('aceptado', 'rechazado'),
                                                IN p_justificacion varchar(255))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_solicitud_existente INT;

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

    -- Verificar si la solicitud de la tarjeta existe
    SELECT COUNT(*) INTO v_solicitud_existente
    FROM solicitud
    WHERE tarjeta_id = p_tarjeta_id;

    IF v_solicitud_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La solicitud de la tarjeta no existe';
    END IF;

    -- Actualizar el estado de la solicitud
    UPDATE solicitud
    SET estado = p_estado, justificacion = p_justificacion
    WHERE tarjeta_id = p_tarjeta_id;

    -- Actualizar el estado de la tarjeta
    UPDATE tarjeta
    SET estado = p_estado
    WHERE tarjeta_id = p_tarjeta_id;

    -- Confirmar la transacción
    COMMIT;

    -- Retornar mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'message', CONCAT('Tarjeta ', p_estado, ' exitosamente')
    ) AS resultado;

END;

CREATE DEFINER=`root`@`%` PROCEDURE `dbmoneybinproy`.`SolicitarPrestamo`(IN p_cuenta_id_or_cui bigint, IN p_monto decimal(15, 2),
                                                   IN p_plazo int, IN p_fecha datetime, IN p_idtipo int,
                                                   IN p_cuota decimal(15, 2))
BEGIN
    DECLARE v_error_message VARCHAR(255);
    DECLARE v_tipo_existente INT;
    DECLARE v_prestamo_id BIGINT;
    DECLARE v_cuenta_id BIGINT;

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

    -- Determinar si es cuenta_id o cui
    SELECT cuenta_id INTO v_cuenta_id
    FROM cuenta
    WHERE cuenta_id = p_cuenta_id_or_cui OR cui = p_cuenta_id_or_cui and vigencia = 'activa';

    IF v_cuenta_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no está registrada';
    END IF;

    -- Validar si el tipo de préstamo existe
    SELECT COUNT(*) INTO v_tipo_existente
    FROM tipo_prestamo
    WHERE tipo_prestamo_id = p_idtipo;

    IF v_tipo_existente = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de préstamo no está registrado';
    END IF;

    -- Insertar el préstamo
    INSERT INTO prestamo (
        cuenta_id,
        monto,
        saldo,
        plazo_meses,
        fecha_solicitud,
        tipo_prestamo_id,
        cuota,
        estado
    ) VALUES (
        v_cuenta_id,
        p_cuota,
        p_monto,
        p_plazo,
        p_fecha,
        p_idtipo,
        p_cuota,
        'pendiente' -- estado inicial del préstamo
    );

    -- Obtener el ID del préstamo recién creado
    SET v_prestamo_id = LAST_INSERT_ID();

    -- Crear una solicitud para el préstamo
    INSERT INTO solicitud (
        prestamo_id,
        estado
    ) VALUES (
        v_prestamo_id,
        'pendiente' -- estado inicial de la solicitud
    );

    -- Confirmar la transacción
    COMMIT;

    -- Retornar el ID del préstamo y un mensaje de éxito
    SELECT JSON_OBJECT(
        'status', 'success',
        'prestamo_id', v_prestamo_id,
        'state', 'pendiente',
        'message', 'Préstamo solicitado exitosamente'
    ) AS resultado;

END;