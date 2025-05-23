const { getConsultarInventario,getRealizarMonitoreo,getAdministradores,getAllEmpleados,getSolicEmpleados,getCancelaciones,getAllEmpleadosMAdmin,getDespidos,genReporte1, genReporte2, genReporte3 } = require('./monitoreo/monitoreo.controller.get')
const { habilitarCambio,habilitarEliminacion,rechazarEliminacion } = require('./monitoreo/monitoreo.controller.put')
const { } = require('./monitoreo/monitoreo.controller.post')

module.exports ={
    getAllEmpleados,
    getConsultarInventario,
    getRealizarMonitoreo,
    getAdministradores,
    getSolicEmpleados,
    getCancelaciones,
    getAllEmpleadosMAdmin,
    habilitarCambio,
    habilitarEliminacion,
    rechazarEliminacion,
    getDespidos,
    genReporte1,
    genReporte2,
    genReporte3
};