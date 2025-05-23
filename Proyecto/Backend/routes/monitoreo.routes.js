const { getConsultarInventario,getRealizarMonitoreo,getAdministradores,getQuejas,getEncuestasSatisfaccion,getAllEmpleados,getSolicEmpleados,getCancelaciones,habilitarCambio, getAllEmpleadosMAdmin, habilitarEliminacion, rechazarEliminacion,getDespidos,genReporte1, genReporte2, genReporte3 } = require('../controllers/monitoreo.controller');
const router = require('express').Router()

// GETS
router.get('/inventario/:sucursal',getConsultarInventario);
router.get('/monitoreo',getRealizarMonitoreo);
router.get('/administradores',getAdministradores);
router.get('/empleados',getAllEmpleados);
router.get('/solicempleados',getSolicEmpleados);
router.get('/get-solicitudes',getCancelaciones);
router.get('/getallempleados',getAllEmpleadosMAdmin)
router.get('/getdespidos',getDespidos)
router.get('/get-reporte1',genReporte1)
router.get('/get-reporte2',genReporte2)
router.get('/get-reporte3',genReporte3)

// PUTS
router.put('/habilitar-cambio',habilitarCambio)
router.put('/habilitar-elim',habilitarEliminacion)
router.put('/rechazar-elim',rechazarEliminacion)

// POST

module.exports = router;