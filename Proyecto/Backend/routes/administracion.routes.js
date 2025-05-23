const { testEndpoint, iniciarSesion, asignarRoles, createAdmin, registrarEmpleado,inicioAdmin,inicioSupervisor,inicioSupervisorfa,inicioAdminfa, getBackup,insertarBackup,getBackupInfo, proxy,updateEmpleado,cambioContraP1,cambioContraP2,realizarEliminacion, sendSolElim } = require('../controllers/administracion.controller');
const router = require('express').Router()

// GETS
router.get('/saldo', testEndpoint);
router.get('/backup-db',getBackup);
router.get('/getbackups',getBackupInfo);
router.get('/proxy-image',proxy); 

// PUTS
router.put('/asignarRol', asignarRoles);
router.put('/update-empleado',updateEmpleado)
router.put('/cambio-pass1',cambioContraP1)
router.put('/cambio-pass2',cambioContraP2)

// POST
router.post('/login', iniciarSesion);
router.post('/loginsup', inicioSupervisor);
router.post('/loginadmin', inicioAdmin);
router.post('/loginadminfa', inicioAdminfa);
router.post('/loginsupfa', inicioSupervisorfa);
router.post('/crearadmin', createAdmin);
router.post('/registrarEmpleado', registrarEmpleado);
router.post('/registrarBackup', insertarBackup);
router.post('/sol-eliminacion',sendSolElim)
router.post('/elim-empleado',realizarEliminacion)

module.exports = router;