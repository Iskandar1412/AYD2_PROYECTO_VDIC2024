const pool = require('../../config/db');
const nodemailer = require('nodemailer');
// const process = require('env')

const {
    BASE_CORREO,
    BASE_CORREO_PASS
} = process.env;

let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: BASE_CORREO,
        pass: BASE_CORREO_PASS
    }
});

async function SendMailMail(mailOptions)  {  // No necesitamos req o res aquí
    try {
        await transporter.sendMail(mailOptions, function(error, info) {
            // console.log(error)
            // console.log(mailOptions)
            if (error) {
                return { success: false, message: 'Error' };  // Solo devolvemos el resultado
            }
        });
        return { success: true, message: 'Correo enviado correctamente' };  // Solo devolvemos el resultado
    } catch (error) {
        return { success: false, message: 'Error al enviar el correo', error };
    }
};


exports.MailToSend = async (req, res) => {
    const data = req.body;
    try {
        const result = await SendMailMail(data) 
        res.status(201).send({ message: result, status: "success" })
    } catch (e) {
        res.status(500).send({ error: 'Error al enviar el correo' })
    }
}