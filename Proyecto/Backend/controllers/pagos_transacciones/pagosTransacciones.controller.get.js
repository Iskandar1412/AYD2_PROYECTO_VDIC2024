const pool = require('../../config/db')

// Pagar Servicio
async function obtenerComprobante(transaccion){
    try {
        const [rows] = await pool.query(`
            CALL GenerarComprobante(?)`,
            [transaccion]
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

exports.getComprobante = async (req,res) =>{
    try{
        const result = await obtenerComprobante(req.params.transaccion);
        res.status(201).send(result);
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar el pago del servicio: ' + error.message });
    }
}