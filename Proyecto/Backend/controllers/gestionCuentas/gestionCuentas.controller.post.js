const pool = require('../../config/db')
const awsS3 = require('../../config/s3')

// Crear Cuenta
async function creacionCuenta(saldo, tipo, fecha_apertura, cui){
    try {
        const [rows] = await pool.query(`
            CALL CrearCuenta(?, ?, ?, ?)`,
            [saldo, tipo, fecha_apertura, cui]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro de la cuenta: '+ error.message)
    }
}

exports.crearCuenta = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await creacionCuenta(data.saldo, data.tipo, currentDate, data.cui);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar la cuenta: ' + error.message });
    }
}

// Depositar Dinero
async function depositoDinero(monto, fecha, cuenta, deposito, moneda, cui_encargado, tipoCuenta){
    try {

        if (monto > 20000) {
            pool.query('INSERT INTO alertas(tipo, fecha, descripcion) values(?, ?, ?);',
                ['Fraude', new Date(), `Se efectua un deposito sospechoso de ${monto} para la cuenta ${cuenta} y el encargado ${cui_encargado}`]
            )
        }

        const [rows] = await pool.query(`
            CALL DepositarDinero(?, ?, ?, ?, ?, ?, ?)`,
            [monto, fecha, cuenta, deposito, moneda, cui_encargado, tipoCuenta]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro del deposito: '+ error.message)
    }
}

exports.depositarDinero = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await depositoDinero(data.monto, currentDate, data.cuenta, data.deposito, data.moneda, data.cui_encargado, data.tipoCuenta);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar el deposito: ' + error.message });
    }
}

// Retirar Dinero
async function retiroDinero(monto, fecha, cuenta, retiro, moneda, cui_encargado, tipoCuenta){
    try {

        if (monto > 20000) {
            pool.query('INSERT INTO alertas(tipo, fecha, descripcion) values(?, ?, ?);',
                ['Fraude', new Date(), `Se efectua un retiro sospechoso de ${monto} para la cuenta ${cuenta} y el encargado ${cui_encargado}`]
            )
        }

        const [rows] = await pool.query(`
            CALL RetirarDinero(?, ?, ?, ?, ?, ?, ?)`,
            [monto, fecha, cuenta, retiro, moneda, cui_encargado, tipoCuenta, tipoCuenta]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro del retiro: '+ error.message)
    }
}

exports.retirarDinero = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await retiroDinero(data.monto, currentDate, data.cuenta, data.retiro, data.moneda, data.cui_encargado, data.tipoCuenta);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar el retiro: ' + error.message });
    }
}

// habilitar cuenta dolares
async function habilitarCuentaDolar(cuenta, tipo, fecha){
    try {
        const [rows] = await pool.query(`
            CALL PermitirCuentaDolar(?, ?, ?)`,
            [cuenta, fecha, tipo]
        );

        // console.log("log fasd")
        // console.log(rows)

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            // console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro de la cuenta: '+ error.message)
    }
}

exports.habilitarCuentaDolar = async (req, res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await habilitarCuentaDolar(data.cuenta, data.tipo, currentDate);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar la cuenta: ' + error.message });
    }
}

// crear cliente
async function crearClienteI(cliente) {
    try {
        // console.log(cliente)
        const fechaHoraActual = new Date();
        const anio = fechaHoraActual.getFullYear().toString();
        const mes = (fechaHoraActual.getMonth() + 1).toString().padStart(2, '0');
        const dia = fechaHoraActual.getDate().toString().padStart(2, '0');
        const hora = fechaHoraActual.getHours().toString().padStart(2, '0');
        const minutos = fechaHoraActual.getMinutes().toString().padStart(2, '0');
        const segundos = fechaHoraActual.getSeconds().toString().padStart(2, '0');
        const fechaHoraNumerica = `${anio}${mes}${dia}${hora}${minutos}${segundos}`;
        const path_nueva_imagen = "Fotos_Perfil/Cliente_"+fechaHoraNumerica+".jpg"
        const path_image = "https://practica1-b-g3-imagenes.s3.amazonaws.com/Fotos_Perfil/Cliente_"+fechaHoraNumerica+".jpg"
        let buff = Buffer.from(cliente.linkFoto,'base64')
        // console.log("siguiente")
        const params = {
            Bucket: "archivosayd2",
            Key: path_nueva_imagen,
            Body: buff,
            ContentType: "image/jpg"
        };

        const putResult = awsS3.putObject(params).promise();
        // console.log("asdf")
        const [rows] = await pool.query(`
            CALL CrearCliente(?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                cliente.nombres, cliente.apellidos, cliente.cui, 
                cliente.telefono, cliente.correo, cliente.direccion,
                cliente.genero,path_image, cliente.fechaNacimiento
            ]
        );
        // console.log(rows)

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro de la cuenta: '+ error.message)
    }
}

exports.crearCliente = async (req, res) =>{
    const data = req.body;
    try{
        const result = await crearClienteI(data);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar la cuenta: ' + error.message });
    }
}

// ENDPOINT REGISTRO DE PREGUNTA
async function PreguntaRespuesta(pregunta, respuesta,id_cuenta){
    try {
        const [rows] = await pool.query(`
            CALL CrearPregunta(?, ?,?)`,
            [pregunta, respuesta,id_cuenta]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el registro de la pregunta y respuesta: '+ error.message)
    }
}

exports.registrarPR = async (req, res) =>{
    const data = req.body;
    try{
        const result = await PreguntaRespuesta(data.pregunta, data.respuesta,data.id_cuenta);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al registrar la pregunta: ' + error.message });
    }
}

// HACER CAMBIO
async function hacerCambioMoneda(cuenta,fecha, monto){
    try {
        const [rows] = await pool.query(`
            CALL HacerCambioMoneda(?,?,?)`,
            [cuenta, monto, fecha]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al realizar el cambio: '+ error.message)
    }
}

exports.cambioMoneda = async (req, res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await hacerCambioMoneda(data.cuenta, currentDate,data.monto);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al realizar el cambio: ' + error.message });
    }
}

//Cargar Papelería
async function regPapeleria(usuario,link_papeleria){
    try{
        const fechaHoraActual = new Date();
        const anio = fechaHoraActual.getFullYear().toString();
        const mes = (fechaHoraActual.getMonth() + 1).toString().padStart(2, '0');
        const dia = fechaHoraActual.getDate().toString().padStart(2, '0');
        const hora = fechaHoraActual.getHours().toString().padStart(2, '0');
        const minutos = fechaHoraActual.getMinutes().toString().padStart(2, '0');
        const segundos = fechaHoraActual.getSeconds().toString().padStart(2, '0');
        const fechaHoraNumerica = `${anio}${mes}${dia}${hora}${minutos}${segundos}`;
        
        
        const path_nuevo_pdf = `Documentos/${usuario}${fechaHoraNumerica}.pdf`;
        const path_pdf = `https://practica1-b-g3-imagenes.s3.amazonaws.com/Documentos/${usuario}${fechaHoraNumerica}.pdf`;


        let buff2 = Buffer.from(link_papeleria, "base64");

        const params2 = {
            Bucket: "archivosayd2",
            Key: path_nuevo_pdf,
            Body: buff2,
            ContentType: "application/pdf"
        };

        const putResult2 = await awsS3.putObject(params2).promise();

        const [rows] = await pool.query(`CALL AgregarPapeleria(?, ?)`, [path_pdf, usuario]);
        return rows[0][0]?.resultado;
    } catch (error) {
        console.log(error)
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.registrarPapeleria = async (req,res) => {
    const data = req.body;
    try{
        const result = await regPapeleria(data.usuario,data.link_papeleria);
        res.status(200).json(result);
    }catch(error) {
        return res.status(500).send({ error: 'Error al cargar papeleria: ' + error.message });
    }
}

// SOLICITUD DE CANCELACION DE TARJETA
async function solCanTarjeta(cuenta,tarjeta,motivo, fecha,tipo){
    try {
        const [rows] = await pool.query(`
            CALL CancelacionTarjeta(?,?,?,?,?)`,
            [cuenta,tarjeta,motivo, fecha,tipo]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al solicitar la cancelación: '+ error.message)
    }
}

exports.sCancelacionTarjeta = async (req, res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await solCanTarjeta(data.cuenta,data.tarjeta,data.motivo, currentDate,data.tipo);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al solicitar la cancelación: ' + error.message });
    }
}

// SOLICITUD DE CANCELACION DE CUENTA
async function solCanCuenta(cuenta,motivo, fecha,tipo){
    try {
        const [rows] = await pool.query(`
            CALL CancelacionCuenta(?,?,?,?)`,
            [cuenta,motivo, fecha,tipo]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al solicitar la cancelación: '+ error.message)
    }
}

exports.sCancelacionCuenta = async (req, res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await solCanCuenta(data.cuenta,data.motivo, currentDate,data.tipo);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al solicitar la cancelación: ' + error.message });
    }
}

// SOLICITUD DE BLOQUEO
async function solBloqueo(tarjeta,titular,pregunta,respuesta,motivo,tipo,fecha){
    try {
        const [rows] = await pool.query(`
            CALL BloquearTarjeta(?,?,?,?,?,?,?)`,
            [tarjeta,titular,pregunta,respuesta,motivo,tipo,fecha]
        );
        const result = rows[0][0]?.resultado;
        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error al solicitar la cancelación: '+ error.message)
    }
}

exports.sBloqueTarjeta = async (req, res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await solBloqueo(data.tarjeta,data.titular,data.pregunta,data.respuesta,data.motivo,data.tipo,currentDate);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al solicitar la cancelación: ' + error.message });
    }
}