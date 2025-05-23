const { registrarPagoTarjeta,getTarjetas,solicitarTarjeta,getSolicTarjetas,aprobTarjeta,getTarjetasPendientes } = require('../controllers/tarjetas.controller');
const router = require('express').Router()

// GETS
router.get('/get-tarjetas/:identificador',getTarjetas)
router.get('/getsol-tarjetas/:cliente',getSolicTarjetas)
router.get('/get-tarjetaspendientes',getTarjetasPendientes)

// PUTS
router.put('/aprob-tarjeta',aprobTarjeta)

// POST
router.post('/pagar-tarjeta',registrarPagoTarjeta)
router.post('/solicitarTarjeta',solicitarTarjeta)
module.exports = router;