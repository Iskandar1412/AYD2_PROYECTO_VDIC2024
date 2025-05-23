const request = require('supertest');
const app = require('./app'); // Importa solo la configuración de la aplicación
const pool = require('./config/db'); // Conexión a la base de datos
let server; // Variable para almacenar el servidor

describe('Pruebas de integración - Endpoint /api/administracion/registrarEmpleado con base de datos', () => {
    beforeAll(async () => {
        // Inicia el servidor antes de las pruebas
        server = app.listen(4000); // Usa un puerto específico para pruebas
        //Limpiar la tabla cambio_empleado con el cui del empleado a registrar
        await pool.query("DELETE FROM cambio_empleado WHERE cui = ?", [2405307990101]);
        // Limpiar la tabla administrado con el cui del empleado a registrar
        await pool.query("DELETE FROM administrador WHERE cui = ?", [2405307990101]);
        // Limpia la base de datos antes de las pruebas
        await pool.query("DELETE FROM empleado WHERE usuario = ?", ['usuario_test']);
        
    });

    afterAll(async () => {
        // Detiene el servidor después de las pruebas
        await server.close();
    });

    test('Debe registrar un empleado correctamente', async () => {
        const response = await request(server) // Usa el servidor activo
            .post('/api/administracion/registrarEmpleado') // Ruta completa al endpoint
            .send({
                cui: 2405307990101,
                nombres: 'Usuario',
                apellidos: 'Testeo',
                telefono: 22002200,
                fecha_nac: '1999-09-09',
                correo: 'user_test@example.com',
                usuario: 'usuario_test',
                password: 'testpass123',
                link_foto: 'base64_image_string', // Simula una imagen en base64
                link_firma: 'base64_signature_string', // Simula una firma en base64
                genero: 'masculino',
                estado_civil: 'soltero',
                sucursal_id: 1,
                link_papeleria: 'base64_pdf_string', // Simula un PDF en base64
            });

        // Verifica que el endpoint responde correctamente
        expect(response.status).toBe(200);
        expect(response.body).toEqual({
            message: "Empleado registrado exitosamente",
            status: "success"
        });

        // Verifica que los datos se guardaron en la base de datos
        const [rows] = await pool.query("SELECT * FROM empleado WHERE usuario = ?", ['usuario_test']);
        expect(rows.length).toBe(1);
        expect(rows[0].nombres).toBe('Usuario');
        expect(rows[0].apellidos).toBe('Testeo');
    });

    test('Debe manejar errores con datos inválidos', async () => {
        const response = await request(server) // Usa el servidor activo
            .post('/api/administracion/registrarEmpleado') // Ruta completa al endpoint
            .send({
                cui: null, // Dato inválido
                nombres: '',
                apellidos: 'Perez',
                telefono: 'invalid', // Dato inválido
                fecha_nac: 'invalid_date', // Fecha inválida
                correo: 'invalid_email',
                usuario: 'usuario_test_error',
                password: '',
                link_foto: 'invalid_base64',
                link_firma: null,
                genero: 'masculino',
                estado_civil: 'soltero',
                sucursal_id: 1,
                link_papeleria: 'invalid_base64',
            });

        // Verifica que el endpoint responde con un error
        expect(response.status).toBe(500);
        expect(response.body.error).toContain('Error al registrar Empleado');
    });
});

describe('Pruebas de integración - Endpoint /asignarRol con base de datos', () => {
    beforeAll(async () => {
        // Inicia el servidor antes de las pruebas
        server = app.listen(4000); // Usa el puerto 4000 para pruebas
    });

    afterAll(async () => {
        // Detiene el servidor después de las pruebas
        await server.close();
    });

    test('Debe asignar un rol correctamente al empleado', async () => {
        // Obtén el ID del usuario creado en las pruebas anteriores
        const [empleados] = await pool.query("SELECT cui FROM empleado WHERE usuario = ?", ['usuario_test']);
        expect(empleados.length).toBe(1); // Verifica que el usuario existe
        const empleado_id = empleados[0].cui;

        // Envía la solicitud PUT para asignar un rol
        const response = await request(server)
            .put('/api/administracion/asignarRol') // Ruta completa al endpoint
            .send({
                empleado_id: empleado_id,
                rol: 'cajero'
            });

        // Verifica que el endpoint responde correctamente
        expect(response.status).toBe(201);
        expect(response.body).toEqual({
            status: 'success',
            message: 'Rol asignado exitosamente'
        });

        // Verifica en la base de datos que el rol fue asignado
        const [roles] = await pool.query("SELECT rol FROM empleado WHERE cui = ?", [empleado_id]);
        expect(roles.length).toBe(1);
        expect(roles[0].rol).toBe('cajero');
    });

    test('Debe manejar errores con datos inválidos', async () => {
        // Envía datos inválidos
        const response = await request(server)
            .put('/api/administracion/asignarRol') // Ruta completa al endpoint
            .send({
                empleado_id: null, // ID inválido
                rol: '' // Rol inválido
            });

        // Verifica que el endpoint responde con un error
        expect(response.status).toBe(500);
        expect(response.body.error).toContain('Error en la asignación de rol');
    });
});

describe('Pruebas de integración - Endpoint /api/administracion/login con base de datos', () => {
    beforeAll(async () => {
        // Inicia el servidor antes de las pruebas
        server = app.listen(4000); // Usa el puerto 4000 para pruebas

        // Verifica que el usuario ya existe en la base de datos
        const [empleados] = await pool.query("SELECT * FROM empleado WHERE usuario = ?", ['usuario_test']);
        if (empleados.length === 0) {
            throw new Error('El usuario usuario_test no existe en la base de datos. Asegúrate de haberlo creado antes de ejecutar esta prueba.');
        }
    });

    afterAll(async () => {
        // Detiene el servidor después de las pruebas
        await server.close();
    });

    test('Debe iniciar sesión correctamente con credenciales válidas', async () => {
        const response = await request(server)
            .post('/api/administracion/login') // Ruta completa al endpoint
            .send({
                usuario: 'usuario_test',
                password: 'testpass123'
            });
        // Obtener la firma del empleado
        const firma = await pool.query("SELECT link_firma FROM empleado WHERE usuario = ?", ['usuario_test']);
        // Verifica que el endpoint responde correctamente
        expect(response.status).toBe(201);
        expect(response.body.message).toEqual({
            cui: 2405307990101,
            link_firma: firma[0][0].link_firma,
            rol: 'cajero',
            status: 'success',
            message: 'Autenticación exitosa',
            nombres: 'Usuario',
            usuario: 'usuario_test',
            apellidos: 'Testeo'
        });
    });

    test('Debe manejar errores con contraseña incorrecta', async () => {
        const response = await request(server)
            .post('/api/administracion/login') // Ruta completa al endpoint
            .send({
                usuario: 'usuario_test',
                password: 'incorrect_password'
            });

        // Verifica que el endpoint responde con un error
        expect(response.status).toBe(201);
        expect(response.body.message).toEqual({
            status: 'error',
            message: 'Ha ocurrido un error: Contraseña incorrecta'
        });
    });

    test('Debe manejar errores con usuario inexistente', async () => {
        const response = await request(server)
            .post('/api/administracion/login') // Ruta completa al endpoint
            .send({
                usuario: 'usuario_inexistente',
                password: 'testpass123'
            });

        // Verifica que el endpoint responde con un error
        expect(response.status).toBe(201);
        expect(response.body.message).toEqual({
            status: 'error',
            message: 'Ha ocurrido un error: Usuario o correo no encontrado'
        });
    });
});


describe('Pruebas de integración - Endpoint /api/administracion/update-empleado', () => {
    beforeAll(async () => {
        // Inicia el servidor antes de las pruebas
        server = app.listen(4000); // Usa el puerto 4000 para pruebas

        // Verifica que el usuario ya existe en la base de datos
        const [empleados] = await pool.query("SELECT * FROM empleado WHERE usuario = ?", ['usuario_test']);
        if (empleados.length === 0) {
            throw new Error('El usuario usuario_test no existe en la base de datos. Asegúrate de haberlo creado antes de ejecutar esta prueba.');
        }
    });

    afterAll(async () => {
        // Detiene el servidor después de las pruebas
        await server.close();
    });

    test('Debe actualizar los datos del empleado correctamente', async () => {
        // Obtén el ID del usuario creado en las pruebas anteriores
        const [empleados] = await pool.query("SELECT cui FROM empleado WHERE usuario = ?", ['usuario_test']);
        expect(empleados.length).toBe(1); // Verifica que el usuario existe
        const identificador = empleados[0].cui;

        // Envía la solicitud PUT para actualizar los datos del empleado
        const response = await request(server)
            .put('/api/administracion/update-empleado') // Ruta completa al endpoint
            .send({
                identificador: identificador,
                telefono: 55001122,
                correo: 'updated_user_test@example.com',
                link_foto: 'base64_image_string_updated', // Nueva imagen en base64
                genero: 'masculino',
                estado_civil: 'casado'
            });

        // Verifica que el endpoint responde correctamente
        expect(response.status).toBe(201);
        expect(response.body.message).toEqual({
            status: 'success',
            message: 'Datos del empleado actualizados exitosamente'
        });

        // Verifica que los datos se actualizaron en la base de datos
        const [updatedEmpleado] = await pool.query("SELECT * FROM empleado WHERE cui = ?", [identificador]);
        expect(updatedEmpleado.length).toBe(1);
        expect(updatedEmpleado[0].telefono).toBe(55001122);
        expect(updatedEmpleado[0].correo).toBe('updated_user_test@example.com');
        expect(updatedEmpleado[0].estado_civil).toBe('casado');
    });

    test('Debe manejar errores con datos inválidos', async () => {
        // Envía datos inválidos
        const response = await request(server)
            .put('/api/administracion/update-empleado') // Ruta completa al endpoint
            .send({
                identificador: null, // Identificador inválido
                telefono: 'invalid_phone', // Teléfono inválido
                correo: 'correo_no_valido',
                link_foto: 'invalid_base64',
                genero: 'masculino',
                estado_civil: ''
            });

        // Verifica que el endpoint responde con un error
        expect(response.status).toBe(500);
        expect(response.body.error).toContain('Error en la actualización de datos');
    });
});


describe('Pruebas de integración - Endpoint /api/administracion/crearadmin', () => {
    beforeAll(async () => {
        // Inicia el servidor antes de las pruebas
        server = app.listen(4000); // Usa un puerto específico para pruebas

        // Limpia cualquier registro anterior del administrador de prueba
        await pool.query("DELETE FROM administrador WHERE cui = ?", [2405307990101]);
    });

    afterAll(async () => {
        // Detiene el servidor después de las pruebas
        await new Promise(resolve => server.close(resolve)); // Cierra el servidor Express correctamente
        await pool.end(); // Cierra la conexión al pool de la base de datos
    });

    test('Debe crear un administrador correctamente', async () => {
        const response = await request(server)
            .post('/api/administracion/crearadmin') // Ruta completa al endpoint
            .send({
                cui: 2405307990101,
                fa: '2fac78787875' // Fecha válida
            });

        // Verifica que el endpoint responde correctamente
        expect(response.status).toBe(201);
        expect(response.body.message).toEqual({
            status: 'success',
            message: 'Rol asignado exitosamente'
        });

        // Verifica que el administrador fue creado y tiene el rol asignado
        const [empleados] = await pool.query("SELECT * FROM empleado WHERE cui = ?", [2405307990101]);
        expect(empleados.length).toBe(1);
        expect(empleados[0].rol).toBe('administrador');
    });

    test('Debe manejar errores con datos inválidos', async () => {
        const response = await request(server)
            .post('/api/administracion/crearadmin') // Ruta completa al endpoint
            .send({
                cui: null, // CUI inválido
                fa: '' // Fecha vacía
            });

        // Verifica que el endpoint responde con un error
        expect(response.status).toBe(500);
        expect(response.body.error).toContain('Error al crear el adminsitrador');
    });
});
