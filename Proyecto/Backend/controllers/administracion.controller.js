const { testEndpoint, getBackup,getBackupInfo, proxy } = require('./administracion/administracion.controller.get')
const { asignarRoles,updateEmpleado,cambioContraP1,cambioContraP2 } = require('./administracion/administracion.controller.put')
const { iniciarSesion,createAdmin,registrarEmpleado,inicioSupervisor,inicioAdmin, inicioAdminfa, inicioSupervisorfa,insertarBackup,sendSolElim,realizarEliminacion } = require('./administracion/administracion.controller.post')

module.exports ={
    testEndpoint,
    iniciarSesion,
    createAdmin,
    registrarEmpleado,
    asignarRoles,
    inicioAdmin,
    inicioSupervisor,
    inicioAdminfa,
    inicioSupervisorfa,
    getBackup,
    insertarBackup,
    getBackupInfo,
    proxy,
    updateEmpleado,
    cambioContraP1,
    cambioContraP2,
    sendSolElim,
    realizarEliminacion
};