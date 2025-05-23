const pool = require('../../config/db')

// Consultar Saldo

async function consultarSaldo(cuenta){
    try{
        const [rows] = await pool.query(`
            CALL MostrarSaldo(?)`,
            [cuenta]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }

    } catch (error) {
        throw new Error('Error en la obtencion del saldo: '+ error.message)
    }
}

exports.getSaldo = async (req,res) =>{
    try {
        const result = await consultarSaldo(req.params.cuenta);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener el saldo de la cuenta: ' + error.message });
    }
}

// Consultar Informacion

async function buscarCuenta(dato){
    try{
        const [rows] = await pool.query(`
            CALL BuscarCuentaCui(?)`,
            [dato]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }

    } catch (error) {
        throw new Error('Error en la obtencion de la informacion: '+ error.message)
    }
}

exports.getCuenta= async (req,res) =>{
    try {
        const result = await buscarCuenta(req.params.dato);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener informacion de la cuenta: ' + error.message });
    }
}

// OBTENER SOLICITUDES DE CANCELACION
async function solCancelacion(cuenta){
    try{
        const [rows] = await pool.query(`
            CALL ObtenerSolicitudesCancelacion(?)`,
            [cuenta]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }

    } catch (error) {
        throw new Error('Error en la obtencion de las solicitudes: '+ error.message)
    }
}

exports.getSolCancelacion= async (req,res) =>{
    try {
        const result = await solCancelacion(req.params.cuenta);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: 'Error en la obtencion de las solicitudes: ' + error.message });
    }
}