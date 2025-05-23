const mysql = require('mysql2/promise')

// const pool = mysql.createPool({
//     host: 'localhost',
//     user: 'root',
//     password: '1234',
//     database: 'dbmoneybinproy',
//     waitForConnections: true,
//     connectionLimit: 10,
//     queueLimit: 0
// })

const pool = mysql.createPool({
    host: process.env.DBHOST,
    user: process.env.DBUSER,
    password: process.env.DBPASSWORD,
    database: process.env.DBDATABASE,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
})

module.exports = pool;