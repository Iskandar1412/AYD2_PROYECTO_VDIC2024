const { getSaldo, getCuenta,getSolCancelacion } = require('./gestionCuentas/gestionCuentas.controller.get')
const { updateCliente,sCancelacionServicio } = require('./gestionCuentas/gestionCuentas.controller.put')
const { crearCuenta, depositarDinero, retirarDinero, habilitarCuentaDolar, crearCliente,registrarPR,cambioMoneda,registrarPapeleria,sCancelacionTarjeta,sCancelacionCuenta,sBloqueTarjeta } = require('./gestionCuentas/gestionCuentas.controller.post')

module.exports ={
    getSaldo,
    crearCuenta,
    getCuenta,
    depositarDinero,
    retirarDinero, 
    habilitarCuentaDolar,
    crearCliente,
    registrarPR,
    updateCliente,
    cambioMoneda,
    registrarPapeleria,
    sCancelacionTarjeta,
    sCancelacionCuenta,
    getSolCancelacion,
    sBloqueTarjeta,
    sCancelacionServicio
};