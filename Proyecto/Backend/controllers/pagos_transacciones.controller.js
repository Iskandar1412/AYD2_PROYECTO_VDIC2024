const { getComprobante } = require('./pagos_transacciones/pagosTransacciones.controller.get')
const { } = require('./pagos_transacciones/pagosTransacciones.controller.put')
const { pagarServicio, pagarPrestamo } = require('./pagos_transacciones/pagosTransacciones.controller.post')

module.exports ={
    pagarServicio,
    getComprobante,
    pagarPrestamo
};