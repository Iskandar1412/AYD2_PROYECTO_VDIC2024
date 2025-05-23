CREATE DATABASE IF NOT EXISTS dbmoneybinproy;
use dbmoneybinproy;
create table cliente
(
    `cui` bigint NOT NULL,
    `nombres` varchar(50) NOT NULL,
    `apellidos` varchar(50) NOT NULL,
    `telefono` bigint NOT NULL,
    `correo` varchar(50) NOT NULL,
    `direccion` varchar(100) NOT NULL,
    `genero` enum('masculino','femenino') NOT NULL,
    `link_foto` varchar(200) NOT NULL,
    `fecha_nac` datetime NOT NULL,
    PRIMARY KEY (`cui`)
);

create table cambio_cliente
(
    `cambio_cliente_id` int NOT NULL AUTO_INCREMENT,
    `cambio` varchar(200) NOT NULL,
    `fecha` datetime NOT NULL,
    `cui` bigint NOT NULL,
    PRIMARY KEY (`cambio_cliente_id`),
    KEY `cambio_cliente_cliente_fk` (`cui`),
    CONSTRAINT `cambio_cliente_cliente_fk` FOREIGN KEY (`cui`) REFERENCES `cliente` (`cui`)
);

create table comentario
(
    `comentario_id` int NOT NULL AUTO_INCREMENT,
    `detalle` varchar(150) NOT NULL,
    `categoria` varchar(50) NOT NULL,
    `tipo` enum('queja','satisfaccion') NOT NULL,
    `fecha` datetime NOT NULL,
    `puntuacion` int DEFAULT NULL,
    `cui` bigint NOT NULL,
    PRIMARY KEY (`comentario_id`),
    KEY `comentario_cliente_fk` (`cui`),
    CONSTRAINT `comentario_cliente_fk` FOREIGN KEY (`cui`) REFERENCES `cliente` (`cui`)
);

create table cuenta
(
    `cuenta_id` bigint NOT NULL AUTO_INCREMENT,
    `saldo` decimal(15,2) NOT NULL,
    `tipo` enum('ahorro','monetaria') NOT NULL,
    `fecha_apertura` datetime NOT NULL,
    `vigencia` enum('activa','inactiva') NOT NULL,
    `cui` bigint NOT NULL,
    PRIMARY KEY (`cuenta_id`),
    KEY `cuenta_cliente_fk` (`cui`),
    CONSTRAINT `cuenta_cliente_fk` FOREIGN KEY (`cui`) REFERENCES `cliente` (`cui`)
);

create table cuenta_dolar
(
    `cuenta_dolar_id` bigint NOT NULL AUTO_INCREMENT,
    `fecha_apertura` datetime NOT NULL,
    `cuenta_id` bigint NOT NULL,
    PRIMARY KEY (`cuenta_dolar_id`),
    UNIQUE KEY `cuenta_dolar__idx` (`cuenta_id`),
    CONSTRAINT `cuenta_dolar_cuenta_fk` FOREIGN KEY (`cuenta_id`) REFERENCES `cuenta` (`cuenta_id`)
);

create table deposito
(
    `deposito_id` int NOT NULL AUTO_INCREMENT,
    `tipo` varchar(50) NOT NULL,
    PRIMARY KEY (`deposito_id`)
);

create table moneda
(
    `moneda_id` int NOT NULL AUTO_INCREMENT,
    `tipo` varchar(25) NOT NULL,
    `cambio_quetzal` decimal(15,2) NOT NULL,
    PRIMARY KEY (`moneda_id`)
);

create table pregunta_seguridad
(
    `pregunta_id` bigint AUTO_INCREMENT
        primary key,
    pregunta_encrip  varchar(200) not null,
    respuesta_encrip varchar(200) not null,
    cuenta_id        bigint      not null,
    constraint pregunta_seguridad__idx
        unique (cuenta_id),
    constraint pregunta_seguridad_cuenta_fk
        foreign key (cuenta_id) references cuenta (cuenta_id)
);

create table retiro
(
    `retiro_id` int NOT NULL AUTO_INCREMENT,
    `tipo` varchar(50) NOT NULL,
    `limite` decimal(15,2) NOT NULL,
    PRIMARY KEY (`retiro_id`)
);

create table servicio
(
    `servicio_id` int NOT NULL AUTO_INCREMENT,
    `tipo` varchar(50) NOT NULL,
    PRIMARY KEY (`servicio_id`)
);

create table sucursal
(
    `sucursal_id` int NOT NULL AUTO_INCREMENT,
    `dinero_disponible` decimal(15,2) NOT NULL,
    PRIMARY KEY (`sucursal_id`)
);

create table empleado
(
    `cui` bigint NOT NULL,
    `usuario` varchar(50) NOT NULL,
    `password` varchar(200) NOT NULL,
    `nombres` varchar(50) NOT NULL,
    `apellidos` varchar(50) NOT NULL,
    `telefono` bigint NOT NULL,
    `correo` varchar(100) NOT NULL,
    `link_foto` varchar(200) NOT NULL,
    `link_firma` varchar(200) DEFAULT NULL,
    `genero` enum('masculino','femenino') NOT NULL,
    `estado_civil` enum('soltero','casado') NOT NULL,
    `fecha_nac` datetime NOT NULL,
    `rol` enum('supervisor','administrador','cajero','atencion','pendiente') NOT NULL,
    `vigencia` enum('activo','inactivo') NOT NULL,
    `sucursal_id` int NOT NULL,
    `link_papeleria` varchar(200) DEFAULT NULL,
    PRIMARY KEY (`cui`),
    KEY `empleado_sucursal_fk` (`sucursal_id`),
    CONSTRAINT `empleado_sucursal_fk` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursal` (`sucursal_id`)
);

create table administrador
(
    `id_administrador` int NOT NULL AUTO_INCREMENT,
    `2FA` varchar(200) NOT NULL,
    `cui` bigint NOT NULL,
    PRIMARY KEY (`id_administrador`),
    KEY `administrador_empleado_fk` (`cui`),
    CONSTRAINT `administrador_empleado_fk` FOREIGN KEY (`cui`) REFERENCES `empleado` (`cui`)
);

create table cambio_empleado
(
    `cambio_empleado_id` int NOT NULL AUTO_INCREMENT,
    `cambio` varchar(200) NOT NULL,
    `fecha` datetime NOT NULL,
    `cui` bigint NOT NULL,
    PRIMARY KEY (`cambio_empleado_id`),
    KEY `cambio_empleado_empleado_fk` (`cui`),
    CONSTRAINT `cambio_empleado_empleado_fk` FOREIGN KEY (`cui`) REFERENCES `empleado` (`cui`)
);

create table cambio_pass
(
    `cambio_pass_id` int NOT NULL AUTO_INCREMENT,
    `password` varchar(200) NOT NULL,
    `estado` enum('pendiente','realizado') NOT NULL,
    `cui` bigint NOT NULL,
    `fecha` datetime,
    PRIMARY KEY (`cambio_pass_id`),
    KEY `cambio_pass_empleado_fk` (`cui`),
    CONSTRAINT `cambio_pass_empleado_fk` FOREIGN KEY (`cui`) REFERENCES `empleado` (`cui`)
);

create table alertas
(
    `alertas_id` int NOT NULL AUTO_INCREMENT,
    `tipo` varchar(200) NOT NULL,
    `fecha` datetime NOT NULL,
    `descripcion` varchar(200) NOT NULL,
    PRIMARY KEY (`alertas_id`)
);

create table despido
(
    `despido_id` int NOT NULL AUTO_INCREMENT,
    `link_doc` varchar(200) NOT NULL,
    `estado` enum('pendiente','realizado') NOT NULL,
    `cui` bigint NOT NULL,
    `fecha` datetime,
    PRIMARY KEY (`despido_id`),
    UNIQUE KEY `despido__idx` (`cui`),
    CONSTRAINT `despido_empleado_fk` FOREIGN KEY (`cui`) REFERENCES `empleado` (`cui`)
);

create table papeleria
(
    `papeleria_id` int NOT NULL AUTO_INCREMENT,
    `link_doc` varchar(200) NOT NULL,
    `cui` bigint NOT NULL,
    PRIMARY KEY (`papeleria_id`),
    KEY `papeleria_empleado_fk` (`cui`),
    CONSTRAINT `papeleria_empleado_fk` FOREIGN KEY (`cui`) REFERENCES `empleado` (`cui`)
);

create table supervisor
(
    `supervisor_id` int NOT NULL AUTO_INCREMENT,
    `usuario` varchar(25) NOT NULL,
    `password` varchar(200) NOT NULL,
    `password2` varchar(200) NOT NULL,
    `cui` bigint NOT NULL,
    PRIMARY KEY (`supervisor_id`),
    KEY `supervisor_empleado_fk` (`cui`),
    CONSTRAINT `supervisor_empleado_fk` FOREIGN KEY (`cui`) REFERENCES `empleado` (`cui`)
);

create table tarjeta
(
    `tarjeta_id` bigint NOT NULL AUTO_INCREMENT,
    `tipo` enum('credito','debito') NOT NULL,
    `limite` decimal(15,2) NOT NULL,
    `titular` varchar(50) NOT NULL,
    `monto` decimal(15,2) NOT NULL,
    `interes` decimal(5,2) NOT NULL,
    `tasa_interes` decimal(5,2) NOT NULL,
    `estado` enum('pendiente','aceptado','rechazado') NOT NULL,
    `vigencia` enum('activa','inactiva') NOT NULL,
    `fecha_solicitud` datetime NOT NULL,
    `cuenta_id` bigint NOT NULL,
    PRIMARY KEY (`tarjeta_id`),
    KEY `tarjeta_cuenta_fk` (`cuenta_id`),
    CONSTRAINT `tarjeta_cuenta_fk` FOREIGN KEY (`cuenta_id`) REFERENCES `cuenta` (`cuenta_id`)
);

create table bloqueo_tarjeta
(
    `bloqueo_id` int NOT NULL AUTO_INCREMENT,
    `fecha` datetime NOT NULL,
    `motivo` enum('robo','perdida','fraude') NOT NULL,
    `tarjeta_id` bigint NOT NULL,
    PRIMARY KEY (`bloqueo_id`),
    UNIQUE KEY `bloqueo_tarjeta__idx` (`tarjeta_id`),
    CONSTRAINT `bloqueo_tarjeta_tarjeta_fk` FOREIGN KEY (`tarjeta_id`) REFERENCES `tarjeta` (`tarjeta_id`)
);

create table cancelacion
(
    `cancelacion_id` int NOT NULL AUTO_INCREMENT,
    `motivo` varchar(100) NOT NULL,
    `fecha_solicitud` datetime NOT NULL,
    `tipo` enum('tarjeta','cuenta') NOT NULL,
    `estado` enum('pendiente','aceptado','rechazado') NOT NULL,
    `cuenta_id` bigint DEFAULT NULL,
    `tarjeta_id` bigint DEFAULT NULL,
    PRIMARY KEY (`cancelacion_id`),
    UNIQUE KEY `cancelacion__idx` (`cuenta_id`),
    UNIQUE KEY `cancelacion__idxv1` (`tarjeta_id`),
    CONSTRAINT `cancelacion_cuenta_fk` FOREIGN KEY (`cuenta_id`) REFERENCES `cuenta` (`cuenta_id`),
    CONSTRAINT `cancelacion_tarjeta_fk` FOREIGN KEY (`tarjeta_id`) REFERENCES `tarjeta` (`tarjeta_id`),
    CONSTRAINT `arc_2` CHECK ((((`cuenta_id` is not null) and (`tarjeta_id` is null)) or ((`tarjeta_id` is not null) and (`cuenta_id` is null))))
);

create table tipo_prestamo
(
    `tipo_prestamo_id` int NOT NULL AUTO_INCREMENT,
    `tipo` varchar(50) NOT NULL,
    PRIMARY KEY (`tipo_prestamo_id`)
);

create table prestamo
(
    `prestamo_id` bigint NOT NULL AUTO_INCREMENT,
    `monto` decimal(15,2) NOT NULL,
    `saldo` decimal(15,2) NOT NULL,
    `cuota` decimal(15,2) NOT NULL,
    `plazo_meses` int NOT NULL,
    `fecha_solicitud` datetime NOT NULL,
    `estado` enum('pendiente','aceptado','rechazado') NOT NULL,
    `tipo_prestamo_id` int NOT NULL,
    `cuenta_id` bigint NOT NULL,
    PRIMARY KEY (`prestamo_id`),
    KEY `prestamo_cuenta_fk` (`cuenta_id`),
    KEY `prestamo_tipo_prestamo_fk` (`tipo_prestamo_id`),
    CONSTRAINT `prestamo_cuenta_fk` FOREIGN KEY (`cuenta_id`) REFERENCES `cuenta` (`cuenta_id`),
    CONSTRAINT `prestamo_tipo_prestamo_fk` FOREIGN KEY (`tipo_prestamo_id`) REFERENCES `tipo_prestamo` (`tipo_prestamo_id`)
);

create table documento
(
    `documento_id` int NOT NULL AUTO_INCREMENT,
    `link_doc` varchar(200) NOT NULL,
    `prestamo_id` bigint NOT NULL,
    PRIMARY KEY (`documento_id`),
    KEY `documento_prestamo_fk` (`prestamo_id`),
    CONSTRAINT `documento_prestamo_fk` FOREIGN KEY (`prestamo_id`) REFERENCES `prestamo` (`prestamo_id`)
);

create table solicitud
(
    `solicitud_id` int NOT NULL AUTO_INCREMENT,
    `prestamo_id` bigint DEFAULT NULL,
    `tarjeta_id` bigint DEFAULT NULL,
    `cancelacion_id` int DEFAULT NULL,
    `justificacion` varchar(255) DEFAULT NULL,
    `estado` enum('pendiente','aceptado','rechazado') NOT NULL,
    PRIMARY KEY (`solicitud_id`),
    UNIQUE KEY `solicitud__idx` (`prestamo_id`),
    UNIQUE KEY `solicitud__idxv1` (`tarjeta_id`),
    UNIQUE KEY `solicitud__idxv2` (`cancelacion_id`),
    CONSTRAINT `solicitud_cancelacion_fk` FOREIGN KEY (`cancelacion_id`) REFERENCES `cancelacion` (`cancelacion_id`),
    CONSTRAINT `solicitud_prestamo_fk` FOREIGN KEY (`prestamo_id`) REFERENCES `prestamo` (`prestamo_id`),
    CONSTRAINT `solicitud_tarjeta_fk` FOREIGN KEY (`tarjeta_id`) REFERENCES `tarjeta` (`tarjeta_id`),
    CONSTRAINT `arc_4` CHECK ((((`prestamo_id` is not null) and (`tarjeta_id` is null) and (`cancelacion_id` is null)) or ((`tarjeta_id` is not null) and (`prestamo_id` is null) and (`cancelacion_id` is null)) or ((`cancelacion_id` is not null) and (`prestamo_id` is null) and (`tarjeta_id` is null))))
);

create table transaccion
(
    `trans_id` bigint NOT NULL AUTO_INCREMENT,
    `monto` decimal(15,2) NOT NULL,
    `tipo` enum('servicio','retiro','deposito','prestamo','tarjeta') NOT NULL,
    `fecha` datetime NOT NULL,
    `cuenta_id` bigint NOT NULL,
    `servicio_id` int DEFAULT NULL,
    `retiro_id` int DEFAULT NULL,
    `deposito_id` int DEFAULT NULL,
    `prestamo_id` bigint DEFAULT NULL,
    `tarjeta_id` bigint DEFAULT NULL,
    `moneda_id` int NOT NULL,
    `empleado_cui` bigint NOT NULL,
    PRIMARY KEY (`trans_id`),
    KEY `transaccion_cuenta_fk` (`cuenta_id`),
    KEY `transaccion_deposito_fk` (`deposito_id`),
    KEY `transaccion_empleado_fk` (`empleado_cui`),
    KEY `transaccion_moneda_fk` (`moneda_id`),
    KEY `transaccion_prestamo_fk` (`prestamo_id`),
    KEY `transaccion_retiro_fk` (`retiro_id`),
    KEY `transaccion_servicio_fk` (`servicio_id`),
    KEY `transaccion_tarjeta_fk` (`tarjeta_id`),
    CONSTRAINT `transaccion_cuenta_fk` FOREIGN KEY (`cuenta_id`) REFERENCES `cuenta` (`cuenta_id`),
    CONSTRAINT `transaccion_deposito_fk` FOREIGN KEY (`deposito_id`) REFERENCES `deposito` (`deposito_id`),
    CONSTRAINT `transaccion_empleado_fk` FOREIGN KEY (`empleado_cui`) REFERENCES `empleado` (`cui`),
    CONSTRAINT `transaccion_moneda_fk` FOREIGN KEY (`moneda_id`) REFERENCES `moneda` (`moneda_id`),
    CONSTRAINT `transaccion_prestamo_fk` FOREIGN KEY (`prestamo_id`) REFERENCES `prestamo` (`prestamo_id`),
    CONSTRAINT `transaccion_retiro_fk` FOREIGN KEY (`retiro_id`) REFERENCES `retiro` (`retiro_id`),
    CONSTRAINT `transaccion_servicio_fk` FOREIGN KEY (`servicio_id`) REFERENCES `servicio` (`servicio_id`),
    CONSTRAINT `transaccion_tarjeta_fk` FOREIGN KEY (`tarjeta_id`) REFERENCES `tarjeta` (`tarjeta_id`),
    CONSTRAINT `arc_3` CHECK ((((`servicio_id` is not null) and (`retiro_id` is null) and (`deposito_id` is null) and (`prestamo_id` is null) and (`tarjeta_id` is null)) or ((`retiro_id` is not null) and (`servicio_id` is null) and (`deposito_id` is null) and (`prestamo_id` is null) and (`tarjeta_id` is null)) or ((`deposito_id` is not null) and (`servicio_id` is null) and (`retiro_id` is null) and (`prestamo_id` is null) and (`tarjeta_id` is null)) or ((`prestamo_id` is not null) and (`servicio_id` is null) and (`retiro_id` is null) and (`deposito_id` is null) and (`tarjeta_id` is null)) or ((`tarjeta_id` is not null) and (`servicio_id` is null) and (`retiro_id` is null) and (`deposito_id` is null) and (`prestamo_id` is null))))
);