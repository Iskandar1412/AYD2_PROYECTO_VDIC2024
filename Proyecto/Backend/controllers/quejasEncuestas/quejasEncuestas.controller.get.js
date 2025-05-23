const pool = require('../../config/db')

// MONITOREO DE QUEJAS
async function extraerQuejas() {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerQuejas()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error al extraer las quejas: ' + error.message)
    }
}

exports.getQuejas = async(req,res) =>{
    try{
        const result = await extraerQuejas();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al extraer quejas: ' + error.message });
    }
}

// MONITOREO DE ENCUESTAS DE SATISFACCIÓN
async function getEncuestas() {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerEncuestas()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error al extraer las encuestas de satisfacción: ' + error.message)
    }
}

exports.getEncuestasSatisfaccion = async(req,res) =>{
    try{
        const result = await getEncuestas();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al extraer las encuestas: ' + error.message });
    }
}