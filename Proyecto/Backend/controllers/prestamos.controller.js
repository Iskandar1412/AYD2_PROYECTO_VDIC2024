const { getPrestamos,getAllPrestamos,getPrestamosPendientes } = require('./prestamos/prestamos.controller.get')
const { aprobPrestamo } = require('./prestamos/prestamos.controller.put')
const { registrarPagoPrestamo,solicitarPrestamo } = require('./prestamos/prestamos.controller.post')

module.exports ={
    registrarPagoPrestamo,
    getPrestamos,
    solicitarPrestamo,
    getAllPrestamos,
    aprobPrestamo,
    getPrestamosPendientes
};