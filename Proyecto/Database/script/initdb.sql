-- Insertar tipos de deposito
INSERT INTO dbmoneybinproy.deposito (tipo)
VALUES 
('efectivo'),
('transferencia');

-- Insertar tipos de retiro

INSERT INTO dbmoneybinproy.retiro (retiro_id, tipo, limite)
VALUES 
(1, 'ventanilla', 20000.00),
(2, 'cajero', 5000.00);

-- Insertar tipos de servicio

INSERT INTO dbmoneybinproy.servicio (servicio_id, tipo)
VALUES
(1, 'agua'),
(2, 'luz'),
(3, 'telefono'),
(4, 'internet');

-- Insertar Tipos de prestamo
INSERT INTO dbmoneybinproy.tipo_prestamo (tipo_prestamo_id, tipo)
VALUES
(1, 'personal'),
(2, 'hipotecario'),
(3, 'vehicular'),
(4, 'educativo');

-- Insertar Sucursal quemada
INSERT INTO dbmoneybinproy.sucursal (sucursal_id, dinero_disponible)
VALUES
(1, 10000000.00);

-- Insertar monedas
INSERT INTO dbmoneybinproy.moneda (moneda_id, tipo, cambio_quetzal)
VALUES
(1, 'quetzal', 1.00),
(2, 'dolar', 7.79);


-- Crear supervisor

CALL RegistrarEmpleado(3848221850101,'Jose David','Panaza Batres',55113538,'2003-06-19 14:30:00','XXXXX@gmail.com','jpanaza','1234','https://i.pinimg.com/564x/9d/6b/9d/9d6b9db2dcb0526a09b89fb35d075c72.jpg','masculino','soltero');

CALL CrearSupervisor(3848221850101,'jpanaza123sup','1234','12345');

CALL AsignacionRol(3848221850101,'supervisor');