const pool = require('../../config/db')

// Pagar Servicio
async function pagoServicio(monto, fecha, cuenta, servicio, cui_encargado){
    try {
        const [rows] = await pool.query(`
            CALL PagarServicio(?, ?, ?, ?, ?, ?)`,
            [monto, fecha, cuenta, servicio, 1, cui_encargado]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro del pago: '+ error.message)
    }
}

exports.pagarServicio = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await pagoServicio(data.monto, currentDate, data.cuenta, data.servicio, data.cui_encargado);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar el pago del servicio: ' + error.message });
    }
}

// Pagar Prestamo
async function pagoPrestamo(monto, fecha, cuenta, prestamo, moneda, cui_encargado){
    try {
        const [rows] = await pool.query(`
            CALL PagarPrestamo(?, ?, ?, ?, ?, ?)`,
            [monto, fecha, cuenta, prestamo, moneda, cui_encargado]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro del pago: '+ error.message)
    }
}

exports.pagarPrestamo = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await pagoPrestamo(data.monto, currentDate, data.cuenta, data.prestamo, data.moneda, data.cui_encargado);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar el pago del prestamo: ' + error.message });
    }
}