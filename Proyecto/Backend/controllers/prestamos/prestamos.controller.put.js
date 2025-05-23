const pool = require('../../config/db')

// APROBACION DE PRESTAMOS
async function aprobacionPrestamo(id_prestamo,estado,justificacion){
    try {
        const [rows] = await pool.query(`
            CALL RevisarPrestamo(?,?,?)`,
            [id_prestamo,estado,justificacion]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la aprobación del prestamo: '+ error.message)
    }
}

exports.aprobPrestamo = async (req,res) =>{
    const data = req.body;
    try{
        const result = await aprobacionPrestamo(data.id_prestamo,data.estado,data.justificacion);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error en la aprobación del prestamo:' + error.message });
    }
}
