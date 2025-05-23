const pool = require('../../config/db')
const awsS3 = require('../../config/s3')


// ASIGNACION DE ROLES
async function asignarRol(empleado_id,rol) {
    try{
        const [rows] = await pool.query(
            `CALL AsignacionRol(?,?)`,
            [empleado_id,rol]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la asignación de rol: ' + error.message)
    }
}

exports.asignarRoles = async (req,res) =>{
    const data = req.body;
    try{
        const result = await asignarRol(data.empleado_id,data.rol);
        res.status(201).send(result);
    } catch (error) {
        res.status(500).send({ error:error.message });
    }
}

// ACTUALIZACIÓN DE DATOS
async function actualizarEMP(identificador,telefono,correo,link_foto,genero,estado_civil){
    try {
        const fechaHoraActual = new Date();
        const anio = fechaHoraActual.getFullYear().toString();
        const mes = (fechaHoraActual.getMonth() + 1).toString().padStart(2, '0');
        const dia = fechaHoraActual.getDate().toString().padStart(2, '0');
        const hora = fechaHoraActual.getHours().toString().padStart(2, '0');
        const minutos = fechaHoraActual.getMinutes().toString().padStart(2, '0');
        const segundos = fechaHoraActual.getSeconds().toString().padStart(2, '0');
        const fechaHoraNumerica = `${anio}${mes}${dia}${hora}${minutos}${segundos}`;
        const path_nueva_imagen = "Fotos_Perfil/"+identificador+fechaHoraNumerica+".jpg"
        const path_image = "https://practica1-b-g3-imagenes.s3.amazonaws.com/Fotos_Perfil/"+identificador+fechaHoraNumerica+".jpg"

        let buff = Buffer.from(link_foto,'base64')
        const params = {
            Bucket: "archivosayd2",
            Key: path_nueva_imagen,
            Body: buff,
            ContentType: "image/jpg"
        };

        const putResult = awsS3.putObject(params).promise();

        const [rows] = await pool.query(`
            CALL ActualizarDEmpleado(?,?,?,?,?,?)`,
            [identificador,telefono,correo,path_image,genero,estado_civil]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la actualización de datos: '+ error.message)
    }
}

exports.updateEmpleado = async (req,res) =>{
    const data = req.body;
    try{
        const result = await actualizarEMP(data.identificador,data.telefono,data.correo,data.link_foto,data.genero,data.estado_civil);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error en la actualización de datos: ' + error.message });
    }
}

// REALIZAR CAMBIO DE CONTRASEÑA
async function cambioP1(cui,contrasenia) {
    try{
        const [rows] = await pool.query(
            `CALL CambioPassWEmpleadoSolicitud(?,?)`,
            [contrasenia,cui]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el paso 1 del cambio de contraseña: ' + error.message)
    }
}

exports.cambioContraP1 = async (req,res) =>{
    const data = req.body;
    try{
        const result = await cambioP1(data.cui,data.contrasenia);
        res.status(201).send(result);
    } catch (error) {
        res.status(500).send({ error:error.message });
    }
}

// ACEPTACION DE CAMBIO DE CONTRASEÑA
async function cambioP2(cui) {
    try{
        const [rows] = await pool.query(
            `CALL CambioPassWEmpleado(?)`,
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
        throw new Error('Error en el paso 2 del cambio de contraseña: ' + error.message)
    }
}

exports.cambioContraP2 = async (req,res) =>{
    const data = req.body;
    try{
        const result = await cambioP2(data.cui);
        res.status(201).send(result);
    } catch (error) {
        res.status(500).send({ error:error.message });
    }
}