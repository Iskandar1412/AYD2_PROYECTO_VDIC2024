const pool = require('../../config/db')

// DEJAR QUEJAS
async function hacerQueja(detalle, categoria,cui,cuenta) {
    try{
        const [rows] = await pool.query(`
            CALL Comentario(?, ?, ?, ?)`,
            [detalle, categoria,cui,cuenta]
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.realizarQueja = async(req,res) =>{
    const data = req.body;
    try{
        const result = await hacerQueja(data.detalle, data.categoria, data.cui, data.cuenta);
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al dejar la queja: ' + error.message });
    }
}

// LLENAR ENCUESTA
async function llenarEncuesta(res1, res2,res3,res4,res5,cui,cuenta,anonimato,categoria) {
    try{
        
        // console.log(cuenta, anonimato, categoria, cui)
        const [rows] = await pool.query(`
            CALL RegistrarEncuesta(?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [res1, res2,res3,res4,res5,cui,cuenta,anonimato, categoria]
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error al registrar la encuesta: ' + error.message)
    }
}

exports.realizarEncuesta = async(req,res) =>{
    const data = req.body;
    // console.log(data)
    try{
        const result = await llenarEncuesta(data.res1,data.res2,data.res3,data.res4,data.res5,data.cui,data.cuenta,data.anonimato, data.categoria);
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al registrar la encuesta: ' + error.message });
    }
}