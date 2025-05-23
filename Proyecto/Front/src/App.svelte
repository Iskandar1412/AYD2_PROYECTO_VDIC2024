<script>
	// import { Router, Route, navigate } from 'svelte-routing';
	import { navigate, Route, Router } from 'svelte-routing';
	import { onMount } from 'svelte';
	import Login from './lib/pages/Login.svelte';
	import { isAuthenticated } from './lib/stores/auth';
	// Base de front al loggear
    import Base from './lib/pages/Base.svelte';
	import ContentHome from './lib/pages/attributes/ContentHome.svelte';
	// Cajero
    import BusquedaCliente from './lib/pages/subpages/Cashier/BusquedaCliente.svelte';
	import PagoPrestamo from './lib/pages/subpages/Cashier/PagoPrestamo.svelte';
	import PagoServicio from './lib/pages/subpages/Cashier/PagoServicio.svelte';
	import RetiroDeposito from './lib/pages/subpages/Cashier/RetiroDeposito.svelte';
	import PagoTarjeta from './lib/pages/subpages/Cashier/PagoTarjeta.svelte';
	import CambioMoneda from './lib/pages/subpages/Cashier/CambioMoneda.svelte';
	// Atencion al Cliente
    import RegistrarCuentaQuet from './lib/pages/subpages/ClientAttention/RegistrarCuentaQuet.svelte';
	import RegistrarCuentaDoll from './lib/pages/subpages/ClientAttention/RegistrarCuentaDoll.svelte';
	import ActualizacionDatosCliente from './lib/pages/subpages/ClientAttention/ActualizacionDatosCliente.svelte';
	import EncuestaSatisfaccion from './lib/pages/subpages/ClientAttention/EncuestaSatisfaccion.svelte';
	import RegistroQuejas from './lib/pages/subpages/ClientAttention/RegistroQuejas.svelte';
	import NuevaTarjeta from './lib/pages/subpages/ClientAttention/NuevaTarjeta.svelte';
	import BloqueoTarjeta from './lib/pages/subpages/ClientAttention/BloqueoTarjeta.svelte';
	import SolicitudPrestamo from './lib/pages/subpages/ClientAttention/SolicitudPrestamo.svelte';
	import SolicitudCancelacionServicio from './lib/pages/subpages/ClientAttention/SolicitudCancelacionServicio.svelte';
    // Administrador de Sistemas
	import CrearEmpleado from './lib/pages/subpages/AdminSys/CrearEmpleado.svelte';
	// import EliminarEmpleado from './lib/pages/subpages/AdminSys/EliminarEmpleado.svelte';
	import RolEmpleado from './lib/pages/subpages/AdminSys/RolEmpleado.svelte';
	import GestionEmpleado from './lib/pages/subpages/AdminSys/GestionEmpleado.svelte';
    // import CambioPass from './lib/pages/subpages/AdminSys/CambioPass.svelte';
	import CopiaSeguridad from './lib/pages/subpages/AdminSys/CopiaSeguridad.svelte';
    // Supervisor
	// import BusquedaEmpleado from './lib/pages/subpages/Supervisor/BusquedaEmpleado.svelte';
	import RegistroAdminSys from './lib/pages/subpages/Supervisor/RegistroAdminSys.svelte';
	// import GestionAdminSys from './lib/pages/subpages/Supervisor/GestionAdminSys.svelte';
	import GestionSolicitudes from './lib/pages/subpages/Supervisor/GestionSolicitudes.svelte';
	import GestionInventarios from './lib/pages/subpages/Supervisor/GestionInventarios.svelte';
	import ReporteEncuestaSatisfaccion from './lib/pages/subpages/Supervisor/ReporteEncuestaSatisfaccion.svelte';
	import ReporteQuejas from './lib/pages/subpages/Supervisor/ReporteQuejas.svelte';
	import Reportes from './lib/pages/subpages/Supervisor/Reportes.svelte';
	import TiempoReal from './lib/pages/subpages/Supervisor/TiempoReal.svelte';
	import GestionAllEmpleados from './lib/pages/subpages/Supervisor/GestionAllEmpleados.svelte';
    
    onMount(() => {})    
    $effect.pre(() => {     
        if($isAuthenticated) {
            navigate('/home')
        } else {
            navigate('/')
        }
    })

</script>

<Router>
    <Route path="/" ><Login /></Route>
    <Route path="/home" >
        <Base Component={ContentHome} />
    </Route>
    <Route path="/MostrarCliente" >
        <Base Component={BusquedaCliente} />
    </Route>
    
    <!-- ---------- Cashier / Cajero ---------- -->
    <Route path="/PagoServicios" >
        <Base Component={PagoServicio} />
    </Route>
    <!-- Servicios -->
    <Route path="/PagoPrestamos" >
        <Base Component={PagoPrestamo} />
    </Route>
    <Route path="/RetiroDeposito" >
        <Base Component={RetiroDeposito} />
    </Route>
    <Route path="/PagoTarjeta" >
        <Base Component={PagoTarjeta} />
    </Route>
    <Route path="/CambioMoneda" >
        <Base Component={CambioMoneda} />
    </Route>

    <!-- ---------- Atencion al Cliente ---------- -->
    <Route path="/CuentaQ" >
        <Base Component={RegistrarCuentaQuet} />
    </Route>
    <Route path="/CuentaExt" >
        <Base Component={RegistrarCuentaDoll} />
    </Route>
    <!-- Gestiones -->
    <Route path="/DatosCliente" >
        <Base Component={ActualizacionDatosCliente} />
    </Route>
    <Route path="/Satisfaccion" >
        <Base Component={EncuestaSatisfaccion} />
    </Route>
    <Route path="/Quejas" >
        <Base Component={RegistroQuejas} />
    </Route>
    <!-- Servicios -->
    <Route path="/NovTarjeta" >
        <Base Component={NuevaTarjeta} />
    </Route>
    <Route path="/BloqTarjeta" >
        <Base Component={BloqueoTarjeta} />
    </Route>
    <Route path="/Prestamos" >
        <Base Component={SolicitudPrestamo} />
    </Route>
    <Route path="/CancelarServicios" >
        <Base Component={SolicitudCancelacionServicio} />
    </Route>

    <!-- ---------- Administrador de Sistemas ---------- -->
    <!-- Gestiones -->
    <Route path="/CreateEmpleado" >
        <Base Component={CrearEmpleado} />
    </Route>
    <Route path="/GestionEmpleados" >
        <Base Component={GestionEmpleado} />
    </Route>
    <!-- <Route path="/EliminacionEmpleado" >
        <Base Component={EliminarEmpleado} />
    </Route> -->
    <Route path="/RolesEmpleados" >
        <Base Component={RolEmpleado} />
    </Route>
    <!-- <Route path="/ChangePassUser" >
        <Base Component={CambioPass} />
    </Route> -->
    <Route path="/SecurityCopy" >
        <Base Component={CopiaSeguridad} />
    </Route>

    <!-- ---------- Supervisor ---------- -->
    <!-- <Route path="/BusquedaEmpleados" >
        <Base Component={BusquedaEmpleado} />
    </Route>
    <Route path="/GestionesAdministrador" >
        <Base Component={GestionAdminSys} />
    </Route> -->
    <Route path="/GestionEmpleadosAdmin" >
        <Base Component={GestionAllEmpleados} />
    </Route>
    <Route path="/AdminRegister" >
        <Base Component={RegistroAdminSys} />
    </Route>
    <!-- Servicios -->
    <Route path="/Solicitud-banc" >
        <Base Component={GestionSolicitudes} />
    </Route>
    <Route path="/Inventary-banc" >
        <Base Component={GestionInventarios} />
    </Route>
    <Route path="/Satisfaccion-banc" >
        <Base Component={ReporteEncuestaSatisfaccion} />
    </Route>
    <Route path="/Quejas-banc" >
        <Base Component={ReporteQuejas} />
    </Route>
    <Route path="/Reports-banc" >
        <Base Component={Reportes} />
    </Route>
    <Route path="/realTime" >
        <Base Component={TiempoReal} />
    </Route>
</Router>

<!-- 'supervisor', 'administrador', 'cajero', 'atencion' -->