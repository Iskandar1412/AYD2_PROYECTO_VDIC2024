const app = require('./app'); // Importa la configuración de la aplicación

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
