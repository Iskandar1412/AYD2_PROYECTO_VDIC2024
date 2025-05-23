const pool = require('../../config/db')
const awsS3 = require('../../config/s3')


// Pagar Servicio
async function loginEmpleado(usuario, password){
    try {
        const [rows] = await pool.query(`
            CALL Login(?, ?)`,
            [usuario, password]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el inicio de sesion: '+ error.message)
    }
}

exports.iniciarSesion = async (req,res) =>{
    const data = req.body;
    try{
        const result = await loginEmpleado(data.usuario, data.password);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al iniciar sesion: ' + error.message });
    }
}

// LOGINS SUPERVISOR
async function logSupervisor(usuario, password){
    try {
        const [rows] = await pool.query(`
            CALL LoginSupervisor(?, ?)`,
            [usuario, password]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el inicio de sesion de supervisor: '+ error.message)
    }
}

exports.inicioSupervisor = async (req,res) =>{
    const data = req.body;
    try{
        const result = await logSupervisor(data.usuario, data.password);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al iniciar sesion en supervisor: ' + error.message });
    }
}

// LOGIN SUP 2FA
async function logSupervisor2f(supervisor_id,password2){
    try {
        const [rows] = await pool.query(`
            CALL LoginSupe2pass(?, ?)`,
            [supervisor_id, password2]
        );

        const result = rows[0][0]?.resultado;
        // console.log(result)
        if (result) {
            return result;
        } else {
            // console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el inicio de sesion de supervisor: '+ error.message)
    }
}

exports.inicioSupervisorfa = async (req,res) =>{
    const data = req.body;
    try{
        const result = await logSupervisor2f(data.id, data.password);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al iniciar sesion en supervisor: ' + error.message });
    }
}

// LOGINS ADMIN
async function logAdmin(usuario, password){
    try {
        const [rows] = await pool.query(`
            CALL LoginAdmin(?, ?)`,
            [usuario, password]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el inicio de sesion de administrador: '+ error.message)
    }
}

exports.inicioAdmin = async (req,res) =>{
    const data = req.body;
    try{
        const result = await logAdmin(data.usuario, data.password,data.password2);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al iniciar sesion en administrador: ' + error.message });
    }
}

// LOGIN ADMIN 2FA
async function logAdmin2fa(id_admin, fa, cui){
    try {
        const [rows] = await pool.query(`
            CALL LoginAdm2fa(?, ?, ?)`,
            [id_admin, fa, cui]
        );

        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el inicio de sesion de administrador: '+ error.message)
    }
}

exports.inicioAdminfa = async (req,res) =>{
    const data = req.body;
    try{
        const result = await logAdmin2fa(data.id, data.password, data.cui);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al iniciar sesion en administrador: ' + error.message });
    }
}

// CREACION DE ADMINISTRADORES
async function crearAdmin(cui, fa) {
    try {
        const [rows] = await pool.query(`CALL CrearAdmin(?, ?)`, [cui, fa]);

        const resultadoCrear = rows[0][0]?.resultado;
        // console.log("Resultado Crear:", resultadoCrear);

        if (!resultadoCrear || resultadoCrear.status !== 'success') {
            throw new Error('Error al crear administrador: ' + (resultadoCrear?.message || 'Resultado no válido'));
        }

        const [rows2] = await pool.query(`CALL AsignacionRol(?, ?)`, [cui, 'administrador']);

        const resultadoRol = rows2[0][0]?.resultado;
        // console.log("Resultado Asignación de Rol:", resultadoRol);

        if (!resultadoRol || resultadoRol.status !== 'success') {
            throw new Error('Error al asignar el rol de administrador: ' + (resultadoRol?.message || 'Resultado no válido'));
        }

        return resultadoRol;
    } catch (error) {
        console.error("Error en crearAdmin:", error.message);
        throw new Error('Error en la creación del administrador: ' + error.message);
    }
}

exports.createAdmin = async (req,res) => {
    const data = req.body;
    try{
        const result = await crearAdmin(data.cui,data.fa);
        res.status(201).send({message: result});
    }catch(error) {
        return res.status(500).send({ error: 'Error al crear el adminsitrador: ' + error.message });
    }
}

// REGISTRO DE EMPLEADOS
async function regEmpleado(cui, nombres, apellidos, telefono, fecha_nac, correo,usuario,password, link_foto,link_firma, genero, estado_civil, sucursal_id,link_papeleria){
    try{
        const fechaHoraActual = new Date();
        const anio = fechaHoraActual.getFullYear().toString();
        const mes = (fechaHoraActual.getMonth() + 1).toString().padStart(2, '0');
        const dia = fechaHoraActual.getDate().toString().padStart(2, '0');
        const hora = fechaHoraActual.getHours().toString().padStart(2, '0');
        const minutos = fechaHoraActual.getMinutes().toString().padStart(2, '0');
        const segundos = fechaHoraActual.getSeconds().toString().padStart(2, '0');
        const fechaHoraNumerica = `${anio}${mes}${dia}${hora}${minutos}${segundos}`;
        const path_nueva_imagen = "Fotos_Perfil/"+usuario+fechaHoraNumerica+".jpg"
        const path_nueva_imagen_firma = "Fotos_Perfil/"+usuario+"_Firma_"+fechaHoraNumerica+".jpg"
        const path_image = "https://practica1-b-g3-imagenes.s3.amazonaws.com/Fotos_Perfil/"+usuario+fechaHoraNumerica+".jpg"
        
        
        const path_nuevo_pdf = `Documentos/${usuario}${fechaHoraNumerica}.pdf`;
        const path_pdf = `https://practica1-b-g3-imagenes.s3.amazonaws.com/PDFs/${usuario}${fechaHoraNumerica}.pdf`;
        // console.log(link_papeleria)
        let buff = Buffer.from(link_foto,'base64')
        if (typeof link_papeleria !== "string" || !link_papeleria.trim()) {
            throw new Error("link_papeleria no es una cadena válida en formato Base64.");
        }

        let buff3
        if(link_firma !== null) {
            buff3 = Buffer.from(link_firma,'base64')
            if (typeof link_papeleria !== "string" || !link_papeleria.trim()) {
                throw new Error("link_papeleria no es una cadena válida en formato Base64.");
            }
        }

        let buff2 = Buffer.from(link_papeleria, "base64");

        // AWS.config.update({
        //     region: 'us-east-1',
        //     accessKeyId: 'XXXXX',
        //     secretAccessKey: 'XXXXX'
        // });
        
        // var s3 = new AWS.S3();

        const params = {
            Bucket: "archivosayd2",
            Key: path_nueva_imagen,
            Body: buff,
            ContentType: "image/jpg"
        };

        const params2 = {
            Bucket: "archivosayd2",
            Key: path_nuevo_pdf,
            Body: buff2,
            ContentType: "application/pdf"
        };

        let path_firma = null
        if(link_firma !== null) {
            path_firma = "https://practica1-b-g3-imagenes.s3.amazonaws.com/Fotos_Perfil/"+usuario+"_Firma_"+fechaHoraNumerica+".jpg"
            const paramsFirma = {
                Bucket: "archivosayd2",
                Key: path_nueva_imagen_firma,
                Body: buff3,
                ContentType: "image/jpg"
            }
            const putResult3 = await awsS3.putObject(paramsFirma).promise();
        }
        const putResult = awsS3.putObject(params).promise();
        const putResult2 = await awsS3.putObject(params2).promise();

        const [rows] = await pool.query(`CALL RegistrarEmpleado(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [cui, nombres, apellidos, telefono, fecha_nac, correo,usuario,password, path_image,path_firma, genero, estado_civil, path_pdf]);
        return rows[0][0]?.resultado;
    } catch (error) {
        console.log(error)
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.registrarEmpleado = async (req,res) => {
    const data = req.body;
    try{
        const result = await regEmpleado(data.cui, data.nombres, data.apellidos, data.telefono, data.fecha_nac, data.correo,data.usuario,data.password, data.link_foto,data.link_firma, data.genero, data.estado_civil, data.sucursal_id,data.link_papeleria);
        res.status(200).json(result);
    }catch(error) {
        return res.status(500).send({ error: 'Error al registrar Empleado: ' + error.message });
    }
}

// REGISTRAR BACKUPS
async function registrarBackup(nombre,link){
    try {
        const [rows] = await pool.query(`
            CALL InsertarBackup(?, ?)`,
            [nombre,link]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro del backup: '+ error.message)
    }
}

exports.insertarBackup = async (req,res) =>{
    const data = req.body;
    try{
        const result = await registrarBackup(data.nombre, data.link);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al insertar backups: ' + error.message });
    }
}

// SOLICITAR ELIMINACIÓN
async function solElim(link_justificacion,cui){
    try {
        const fechaHoraActual = new Date();
        const anio = fechaHoraActual.getFullYear().toString();
        const mes = (fechaHoraActual.getMonth() + 1).toString().padStart(2, '0');
        const dia = fechaHoraActual.getDate().toString().padStart(2, '0');
        const hora = fechaHoraActual.getHours().toString().padStart(2, '0');
        const minutos = fechaHoraActual.getMinutes().toString().padStart(2, '0');
        const segundos = fechaHoraActual.getSeconds().toString().padStart(2, '0');
        const fechaHoraNumerica = `${anio}${mes}${dia}${hora}${minutos}${segundos}`;
        
        const path_nuevo_pdf = `Documentos/${cui}${fechaHoraNumerica}.pdf`;
        const path_pdf = `https://archivosayd2.s3.us-east-1.amazonaws.com/Documentos/${cui}${fechaHoraNumerica}.pdf`;

        let buff2 = Buffer.from(link_justificacion, "base64");

        const params2 = {
            Bucket: "archivosayd2",
            Key: path_nuevo_pdf,
            Body: buff2,
            ContentType: "application/pdf"
        };
        
        const putResult2 = await awsS3.putObject(params2).promise();

        const [rows] = await pool.query(`
            CALL EliminarEmpleadoSolicitud(?, ?)`,
            [path_pdf,cui]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la solicitud de eliminación: '+ error.message)
    }
}

exports.sendSolElim = async (req,res) =>{
    const data = req.body;
    try{
        const result = await solElim(data.link_justificacion, data.cui);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error en la solicitud de eliminación: ' + error.message });
    }
}

// REALIZAR ELIMINACIÓN
async function elimEmpleado(cui){
    try {
        const [rows] = await pool.query(`
            CALL EliminarEmpleado(?)`,
            [cui]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la eliminación del empleado: '+ error.message)
    }
}

exports.realizarEliminacion = async (req,res) =>{
    const data = req.body;
    try{
        const result = await elimEmpleado(data.cui);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al insertar backups: ' + error.message });
    }
}