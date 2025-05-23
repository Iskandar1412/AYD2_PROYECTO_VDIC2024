const pool = require('../../config/db')

//Get Inventario
async function consultarInventario(sucursal) {
    try{
        const [rows] = await pool.query(`
            CALL GestionInventario(?)`,
            [sucursal]
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en la consulta del inventario: ' + error.message)
    }
}

exports.getConsultarInventario = async(req,res) =>{
    try{
        const result = await consultarInventario(req.params.sucursal);
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener el inventario de la sucursal: ' + error.message });
    }
}

// GET MONITOREO GENERAL
async function realizarMonitoreo(sucursal) {
    try{
        const conteosPromise = pool.query(`
            CALL Monitoreo()`
        )
        const actividadesAdminPromise = pool.query(`
            SELECT 
                e.usuario, 
                e.nombres, 
                e.fecha_nac,
                e.apellidos,
                e.rol,
                CASE
                    WHEN ce.cui IS NOT NULL THEN ce.cambio
                    WHEN cp.cui IS NOT NULL THEN 'Cambio contraseña'
                END AS cambio,
                CASE
                    WHEN ce.cui IS NOT NULL THEN ce.fecha
                    WHEN cp.cui IS NOT NULL THEN cp.fecha 
                END AS fecha,
                (
                    SELECT COUNT(*)
                    FROM cambio_pass cp_sub
                    WHERE cp_sub.cui = e.cui
                ) AS cambios_contra
            FROM 
                empleado e
            LEFT JOIN 
                cambio_empleado ce ON e.cui = ce.cui
            LEFT JOIN 
                cambio_pass cp ON e.cui = cp.cui AND cp.estado = 'realizado'
            WHERE 
                ce.cui IS NOT NULL OR cp.cui IS NOT NULL;
        `)
        
        const despidosPromise = pool.query(`
            SELECT 
                e.usuario, 
                e.nombres,
                e.apellidos,
                d.fecha
            FROM 
                empleado e inner join despido d
                on e.cui = d.cui 
            WHERE 
                d.estado = 'realizado';`
        )

        const alertasPromise = pool.query(`
            SELECT * from alertas;
            `)

        const [[rows], [actividadesAdmin], [despidos], [alertas]] = await Promise.all([conteosPromise, actividadesAdminPromise, despidosPromise, alertasPromise])
        //console.log(resultados)
        const result = rows[0][0]?.resultado;
        
        if (result && actividadesAdmin) {
            let bodyResponse = {
                ...result,
                actividadesAdmin: actividadesAdmin,
                despidos: despidos,
                alertas: alertas,
                status: 'success'
            }
            return bodyResponse;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el monitoreo: ' + error.message)
    }
}


exports.getRealizarMonitoreo = async(req,res) =>{
    try{
        const result = await realizarMonitoreo();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener el inventario de la sucursal: ' + error.message });
    }
}

// OBTENCIÓN DE DATA DE ADMINISTRADORES
async function extraerAdministradores(sucursal) {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerAdministradores()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error al extraer los administradores: ' + error.message)
    }
}

exports.getAdministradores = async(req,res) =>{
    try{
        const result = await extraerAdministradores();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener a los administradores: ' + error.message });
    }
}

// OBTENCIÓN DE TODOS LOS Empleados
async function extrearEmpleados() {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerTodosLosEmpleados()`
        )

        // console.log(rows[0])
        const result = rows[0][0].resultado;

        if (result) {
            return result;
        }else{
            // console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.getAllEmpleados = async(req,res) =>{
    try{
        const result = await extrearEmpleados();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener los empleados: ' + error.message });
    }
}

// OBTENCIÓN DE SOLICITUDES EMPLEADOS
async function extraerSolicEmpleados() {
    try{
        const [rows] = await pool.query(`
             CALL ExtraerSolicitudEmpleados()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.getSolicEmpleados = async(req,res) =>{
    try{
        const result = await extraerSolicEmpleados();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener los empleados: ' + error.message });
    }
}

// SOLICITUDES DE CANCELACION
async function extraerSolCancelacion() {
    try{
        const [rows] = await pool.query(`
             CALL ExtraerSolicitudesCancelacionPendientes()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.getCancelaciones = async(req,res) =>{
    try{
        const result = await extraerSolCancelacion();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener las solicitudes de cancelacion: ' + error.message });
    }
}

// OBTENCIÓN DE TODOS LOS EMPLEADOS MENOS ADMINISRTRADORES
async function extrearEmpleadosMadmin() {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerTodosLosEmpleadosMAdmin()`
        )

        // console.log(rows[0])
        const result = rows[0][0].resultado;

        if (result) {
            return result;
        }else{
            // console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.getAllEmpleadosMAdmin = async(req,res) =>{
    try{
        const result = await extrearEmpleadosMadmin();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener los empleados: ' + error.message });
    }
}

// OBTENCIÓN DE DESPIDOS
async function extraerDespidos() {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerDespidos()`
        )

        // console.log(rows[0])
        const result = rows[0][0].resultado;

        if (result) {
            return result;
        }else{
            // console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en el procedimiento: ' + error.message)
    }
}

exports.getDespidos = async(req,res) =>{
    try{
        const result = await extraerDespidos();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener los despidos: ' + error.message });
    }
}

// REPORTE 1
async function genReporte1() {
    try{
        const [rows] = await pool.query(`
            CALL obtenerDatosIngresosGastos()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en la consulta del inventario: ' + error.message)
    }
}

exports.genReporte1 = async(req,res) =>{
    try{
        const result = await genReporte1();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error al obtener el reporte 1: ' + error.message });
    }
}

// REPORTE 2
async function genReporte2() {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerResumenPrestamosGlobal()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en la consulta de prestamos: ' + error.message)
    }
}

exports.genReporte2 = async(req,res) =>{
    try{
        const result = await genReporte2();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error en la consulta de prestamos: ' + error.message });
    }
}

// REPORTE 3
async function genReporte3() {
    try{
        const [rows] = await pool.query(`
            CALL ExtraerAVGEncuestas()`
        )

        const result = rows[0][0]?.resultado;

        if (result) {
            return result;
        }else{
            console.log(result);
            throw new Error('Error en el procedimiento');
        }
    }catch (error){
        throw new Error('Error en la consulta de prestamos: ' + error.message)
    }
}

exports.genReporte3 = async(req,res) =>{
    try{
        const result = await genReporte3();
        res.status(200).json(result);
    }catch(error){
        res.status(500).json({ error: 'Error en la consulta de avg: ' + error.message });
    }
}