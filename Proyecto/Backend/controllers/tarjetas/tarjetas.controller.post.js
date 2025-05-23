const pool = require('../../config/db')

// PAGO DE TARJETAS
async function regPagoTarjeta(monto,fecha,cuenta,tarjeta,encargado){
    try {
        const [rows] = await pool.query(`
            CALL PagarTarjeta(?,?,?,?,?,?)`,
            [monto,fecha,cuenta,tarjeta,1,encargado]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el pago de la tarjeta: '+ error.message)
    }
}

exports.registrarPagoTarjeta = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await regPagoTarjeta(data.monto,currentDate,data.cuenta,data.tarjeta,data.encargado);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error en el pago de la tarjeta: ' + error.message });
    }
}


// SOLICITUD DE TARJETAS
async function solTarjeta(cuenta,tipo,limite,fecha,encargado){
    try {
        const [rows] = await pool.query(`
            CALL CrearTarjeta(?,?,?,?,?)`,
            [cuenta,tipo,limite,fecha,encargado]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la solicitud de la tarjeta: '+ error.message)
    }
}

exports.solicitarTarjeta = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await solTarjeta(data.cuenta,data.tipo,data.limite,currentDate,data.encargado);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error en la solicitud de la tarjeta: '+ error.message});
    }
}
