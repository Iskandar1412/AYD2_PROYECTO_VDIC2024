const express = require("express");
const cors = require("cors");
require('dotenv').config();

const app = express();

app.use(express.json({ limit: "100mb" }));
app.use(express.urlencoded({ limit: "100mb", extended: true }));
app.use(cors({ origin: '*' }));

// IMPORTACIÓN DE ARCHIVOS DE LAS RUTAS
app.use("/api/administracion", require("./routes/administracion.routes"));
app.use("/api/gestion", require("./routes/gestionCuentas.routes"));
app.use("/api/monitoreo", require("./routes/monitoreo.routes"));
app.use("/api/transacciones", require("./routes/pagos_transacciones.routes"));
app.use("/api/prestamos", require("./routes/prestamos.routes"));
app.use("/api/quejasEncuestas", require("./routes/quejasEncuestas.routes"));
app.use("/api/tarjetas", require("./routes/tarjetas.routes"));
app.use('/api/mail', require('./routes/mail.routes'));

module.exports = app; // Exporta la configuración de la aplicación
