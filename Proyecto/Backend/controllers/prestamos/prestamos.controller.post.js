const pool = require('../../config/db')
const awsS3 = require('../../config/s3')

// SOLICITAR PRESTAMOS
async function solPrestamo(identificador,monto,plazo,fecha,tipo,cuota,link_papeleria){
    try {
        const fechaHoraActual = new Date();
        const anio = fechaHoraActual.getFullYear().toString();
        const mes = (fechaHoraActual.getMonth() + 1).toString().padStart(2, '0');
        const dia = fechaHoraActual.getDate().toString().padStart(2, '0');
        const hora = fechaHoraActual.getHours().toString().padStart(2, '0');
        const minutos = fechaHoraActual.getMinutes().toString().padStart(2, '0');
        const segundos = fechaHoraActual.getSeconds().toString().padStart(2, '0');
        const fechaHoraNumerica = `${anio}${mes}${dia}${hora}${minutos}${segundos}`;
        
        
        const path_nuevo_pdf = `Documentos/${identificador}${fechaHoraNumerica}.pdf`;
        const path_pdf = `https://archivosayd2.s3.us-east-1.amazonaws.com/Documentos/${identificador}${fechaHoraNumerica}.pdf`;


        let buff2 = Buffer.from(link_papeleria, "base64");

        const params2 = {
            Bucket: "archivosayd2",
            Key: path_nuevo_pdf,
            Body: buff2,
            ContentType: "application/pdf"
        };

        const putResult2 = await awsS3.putObject(params2).promise();

        const [rows] = await pool.query(`
            CALL SolicitarPrestamo(?,?,?,?,?,?,?)`,
            [identificador,monto,plazo,fecha,tipo,cuota, path_pdf]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la solicitud del prestamo: '+ error.message)
    }
}

exports.solicitarPrestamo = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await solPrestamo(data.identificador,data.monto,data.plazo,currentDate,data.tipo,data.monto/data.plazo,data.link_papeleria);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error en la solicitud del prestamo: '+ error.message});
    }
}


// PAGO DEL PRESTAMO
async function regPagoPrestamo(monto,fecha,cuenta,prestamo,encargado){
    try {
        const [rows] = await pool.query(`
            CALL PagarPrestamo(?,?,?,?,?,?)`,
            [monto,fecha,cuenta,prestamo,1,encargado]
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en el pago del prestamo: '+ error.message)
    }
}

exports.registrarPagoPrestamo = async (req,res) =>{
    const data = req.body;
    try{
        const currentDate = new Date().toISOString().split('T')[0];
        const result = await regPagoPrestamo(data.monto,currentDate,data.cuenta,data.prestamo,data.encargado);
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al pagar el prestamo: ' + error.message });
    }
}
