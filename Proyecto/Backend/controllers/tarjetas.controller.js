const { getTarjetas,getSolicTarjetas,getTarjetasPendientes } = require('./tarjetas/tarjetas.controller.get')
const { aprobTarjeta } = require('./tarjetas/tarjetas.controller.put')
const { registrarPagoTarjeta,solicitarTarjeta } = require('./tarjetas/tarjetas.controller.post')

module.exports ={
    registrarPagoTarjeta,
    getTarjetas,
    solicitarTarjeta,
    getSolicTarjetas,
    aprobTarjeta,
    getTarjetasPendientes
};