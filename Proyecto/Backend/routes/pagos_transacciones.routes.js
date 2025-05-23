const { pagarServicio, getComprobante, pagarPrestamo } = require('../controllers/pagos_transacciones.controller');
const router = require('express').Router()

// GETS
router.get('/generar-comprobante/:transaccion', getComprobante);

// PUTS


// POST
router.post('/pagar-servicio', pagarServicio);
router.post('/pagar-prestamo', pagarPrestamo);

module.exports = router;