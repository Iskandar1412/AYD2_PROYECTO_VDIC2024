const pool = require('../../config/db')

// HABILITACIÓN DE CAMBIO
async function habPass(cui) {
    try{
        const [rows] = await pool.query(`
            CALL HabilitarCambioPass(?)`,
            [cui]
        )

        // console.log(rows[0])
        const result = rows[0][0].resultado;

        if (result) {
            return result;
        }else{
            // console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.habilitarCambio = async(req,res) =>{
    const data = req.body;
    try{
        const result = await habPass(data.cui);
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al tratar de habilitar el cambio: ' + error.message });
    }
}

// HABILITACIÓN DE ELIMINACION
async function habElim(cui) {
    try{
        const [rows] = await pool.query(`
            CALL HabilitarEliminacion(?)`,
            [cui]
        )

        // console.log(rows[0])
        const result = rows[0][0].resultado;

        if (result) {
            return result;
        }else{
            // console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.habilitarEliminacion = async(req,res) =>{
    const data = req.body;
    try{
        const result = await habElim(data.cui);
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al tratar de cambiar el estado de eliminación: ' + error.message });
    }
}

// RECHAZO DE SOLICITUD DE ELIMINACION
async function rechElim(cui) {
    try{
        const [rows] = await pool.query(`
            CALL EliminarSolElim(?)`,
            [cui]
        )

        // console.log(rows[0])
        const result = rows[0][0].resultado;

        if (result) {
            return result;
        }else{
            // console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.rechazarEliminacion = async(req,res) =>{
    const data = req.body;
    try{
        const result = await rechElim(data.cui);
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al tratar de rechazar el despido: ' + error.message });
    }
}