const { registrarPagoPrestamo,getPrestamos,solicitarPrestamo,getAllPrestamos,aprobPrestamo,getPrestamosPendientes } = require('../controllers/prestamos.controller');
const router = require('express').Router()

// GETS
router.get('/obtener-prestamos/:identificador',getPrestamos)
router.get('/get-pendprestamos',getPrestamosPendientes)
router.get('/get-allprestamos/:identificador',getAllPrestamos)

// PUTS
router.put('/aprobacion-prestamo',aprobPrestamo)

// POST
router.post('/pago-prestamo',registrarPagoPrestamo)
router.post('/sol-prestamo',solicitarPrestamo)

module.exports = router;