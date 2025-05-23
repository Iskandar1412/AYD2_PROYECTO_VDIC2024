const pool = require('../../config/db')

// ENDPOINT REGISTRO DE PREGUNTA
async function actualizacionCliente(cuenta, telefono, direccion,correo){
    try {

        // console.log(cuenta, telefono, direccion, correo)
        const [rows] = await pool.query(`
            CALL ActualizarDCliente(?, ?, ?, ?)`,
            [cuenta, telefono, correo, direccion]
        );
        
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            // console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la actualización de datos: '+ error.message)
    }
}

exports.updateCliente = async (req, res) =>{
    const data = req.body;
    try{
        const result = await actualizacionCliente(data.cuenta, data.telefono, data.direccion,data.correo);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al actualizar los datos del Cliente: ' + error.message });
    }
}


// APROBACIÓN DE SOLICITUDES
async function solCanServ(id_cancelacion,estado,justificacion){
    try {
        const [rows] = await pool.query(`
            CALL RevisarCancelacion(?,?,?)`,
            [id_cancelacion,estado,justificacion]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al aprobar la cancelación de servicios: '+ error.message)
    }
}

exports.sCancelacionServicio = async (req, res) =>{
    const data = req.body;
    try{
        const result = await solCanServ(data.id_cancelacion,data.estado,data.justificacion);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al aprobar la cancelación de servicios: ' + error.message });
    }
}