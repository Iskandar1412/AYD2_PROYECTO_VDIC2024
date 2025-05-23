const { getSaldo, crearCuenta, getCuenta, depositarDinero, retirarDinero, habilitarCuentaDolar, crearCliente,registrarPR,updateCliente,cambioMoneda,registrarPapeleria,sCancelacionTarjeta,sCancelacionCuenta,getSolCancelacion,sBloqueTarjeta,sCancelacionServicio } = require('../controllers/gestionCuentas.controller');
const router = require('express').Router()

// GETS
router.get('/saldo/:cuenta', getSaldo);
router.get('/cuenta/:dato', getCuenta);
router.get('/get-sol-cancelacion/:cuenta',getSolCancelacion);

// PUTS
router.put('/actualizar-datos',updateCliente)
router.put('/aprob-cancelacion',sCancelacionServicio)

// POST
router.post('/crear-cuenta', crearCuenta);
router.post('/deposito', depositarDinero);
router.post('/retiro', retirarDinero);
router.post('/cuenta/dolares', habilitarCuentaDolar)
router.post('/cliente', crearCliente)
router.post('/registrar-pr',registrarPR)
router.post('/cambio-moneda',cambioMoneda)
router.post('/cargar-papeleria',registrarPapeleria)
router.post('/sol-cancelacion-t',sCancelacionTarjeta)
router.post('/sol-cancelacion-c',sCancelacionCuenta)
router.post('/bloqueo-tarjeta',sBloqueTarjeta)

module.exports = router;