const pool = require('../../config/db')

// OBTENER PRESTAMOS
async function obtenerTarjetas(identificador){
    try {
        const [rows] = await pool.query(`
            CALL ExtraerTarjetasAceptadas(?)`,
            [identificador]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al obtener las tarjetas: '+ error.message)
    }
}

exports.getTarjetas = async (req,res) =>{

    try{
        const result = await obtenerTarjetas(req.params.identificador);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al obtener las tarjetas:' + error.message });
    }
}

// OBTENER SOLICITUDES 
async function obtenerSolTarjetas(cliente){
    try {
        const [rows] = await pool.query(`
            CALL ObtenerSolicitudesTarjetasDetalles(?)`, [cliente]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            // console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al obtener las tarjetas: '+ error.message)
    }
}

exports.getSolicTarjetas = async (req,res) =>{
    // console.log(req.params)
    try{
        const result = await obtenerSolTarjetas(req.params.cliente);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al obtener las tarjetas:' + error.message });
    }
}

// OBTENER TODOS LOS PENDIENTES
async function obtenerTPendientes(){
    try {
        const [rows] = await pool.query(`
            CALL ExtraerTarjetasPendientes()`
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al obtener las tarjetas: '+ error.message)
    }
}

exports.getTarjetasPendientes = async (req,res) =>{
    try{
        const result = await obtenerTPendientes();
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al obtener las tarjetas: ' + error.message });
    }
}