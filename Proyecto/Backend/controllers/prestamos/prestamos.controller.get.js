const pool = require('../../config/db')
// OBTENER TODOS LOS PRESTAMOS
async function obtenerAllPrestamos(identificador){
    try {
        const [rows] = await pool.query(`
            CALL ExtraerPrestamos(?)`,
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
        throw new Error('Error al obtener los prestamos: '+ error.message)
    }
}

exports.getAllPrestamos = async (req,res) =>{
    try{
        const result = await obtenerAllPrestamos(req.params.identificador);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al obtener los prestamos: ' + error.message });
    }
}



// OBTENER PRESTAMOS ACEPTADOS
async function obtenerPrestamos(identificador){
    try {
        const [rows] = await pool.query(`
            CALL ExtraerPrestamosAceptados(?)`,
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
        throw new Error('Error al obtener los prestamos: '+ error.message)
    }
}

exports.getPrestamos = async (req,res) =>{
    try{
        const result = await obtenerPrestamos(req.params.identificador);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al pagar el prestamo: ' + error.message });
    }
}

// OBTENER TODOS LOS PENDIENTES
async function obtenerPPrestamos(){
    try {
        const [rows] = await pool.query(`
            CALL ExtraerPrestamosPendientes()`
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al obtener los prestamos: '+ error.message)
    }
}

exports.getPrestamosPendientes = async (req,res) =>{
    try{
        const result = await obtenerPPrestamos();
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al obtener los prestamos: ' + error.message });
    }
}