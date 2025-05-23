const pool = require('../../config/db')
const awsS3 = require('../../config/s3')
const { Client } = require('ssh2');
const fs = require('fs');
const path = require('path');
const axios = require('axios')

exports.testEndpoint = async (req,res) =>{
    res.send("Endpoint administracion");
}

exports.getBackup = async (req,res) =>{
    try {
        const backupFileName = `backup_${new Date().toISOString().replace(/[-T:\.Z]/g, '')}.sql`;
        const backupFilePath = path.join('/tmp', backupFileName).replace(/\\/g, "/");
        const remoteBackupPath = backupFilePath;
        const localBackupPath = `/tmp/${backupFileName}`;
        const backupCommand = `docker exec ${process.env.DBCONTAINTER} mysqldump -u${process.env.DBUSER} -p${process.env.DBPASSWORD} ${process.env.DBDATABASE} > ${backupFilePath}`;
        const sshClient = new Client();
        const config = {
            host: process.env.SSHHOST,
            port: 22,
            username: process.env.SSHUSER,
            privateKey: require('fs').readFileSync(process.env.PATHPEM)
        };
        sshClient.on('ready', () => {
            console.log('Conexión SSH establecida.');
            sshClient.exec(backupCommand, (err, stream) => {
                if (err) {
                    console.log('Error ejecutando el comando:', err);
                    sshClient.end();
                    return;
                }
                stream.on('close', (code, signal) => {
                    if (code === 0) {
                        // Descargar el archivo de backup al sistema local
                        sshClient.sftp((err, sftp) => {
                            if (err) {
                                res.status(500).send('Error in SFTP');
                                sshClient.end();
                                return;
                            }
                            sftp.fastGet(remoteBackupPath, localBackupPath, (err) => {
                                if (err) {
                                    res.status(500).send('Error downloading backup');
                                    sshClient.end();
                                    return;
                                }
                                console.log('Backup downloaded successfully.');
                                // Subir el archivo a S3
                                const fileStream = fs.createReadStream(localBackupPath);
                                const s3Params = {
                                    Bucket: `${process.env.BACKUP_S3_BUCKET}`,
                                    Key: `${backupFileName}`,
                                    Body: fileStream,
                                    ContentType: 'application/sql'
                                };
                                awsS3.upload(s3Params, (err, data) => {
                                    if (err) {
                                        console.error('Error uploading to S3:', err);
                                        res.status(500).send({ error: 'Error al obtener el bakcup: ' + err.message });
                                    } else {
                                        console.log('File uploaded to S3:', data.Location);
                                        res.status(200).send({'message': data.Location});
                                    }
                                    fs.unlinkSync(localBackupPath);
                                    sshClient.end();
                                });
                            });
                        });
                    } else {
                        console.error('SSH Connection error:', err);
                        res.status(500).send({ error: 'Error al obtener el bakcup: ' + err.message });
                    }
                }).on('data', (data) => {
                    console.log('STDOUT:', data.toString());
                }).stderr.on('data', (data) => {
                    console.log('STDERR:', data.toString());
                });
            });
        }).connect(config);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener el bakcup: ' + error.message });
    }
}

async function obtenerInfoBackup(){
    try {
        const [rows] = await pool.query(`
            CALL ExtraerBackups()`
        );

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        } else {
            console.log(result);
            throw new Error('Resultado inesperado del procedimiento');
        }
    } catch (error) {
        throw new Error('Error en la obtención de backups: '+ error.message)
    }
}

exports.getBackupInfo = async (req,res) =>{
    try{
        const result = await obtenerInfoBackup();
        res.status(201).send({ message: result });
    } catch (error) {
        res.status(500).send({ error: 'Error al retornar backups: ' + error.message });
    }
}

exports.proxy = async (req, res) => {
    const { url } = req.query; // URL de la imagen proporcionada por el backend
    if (!url) {
        return res.status(400).json({ error: 'Falta la URL de la imagen.' });
    }

    try {
        // Hacer la solicitud GET al servidor S3
        const response = await axios.get(url, { responseType: 'arraybuffer' });

        // Enviar los datos de la imagen al frontend
        res.setHeader('Content-Type', response.headers['content-type']);
        res.send(response.data);
    } catch (error) {
        console.error('Error al obtener la imagen:', error.message);
        res.status(500).json({ error: 'No se pudo obtener la imagen.' });
    }
};