<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";
	// import CrecimientoVsPrestamo from "./Reportes/CrecimientoVsPrestamo.svelte";
	import DesempenoLaboral from "./Reportes/DesempenoLaboral.svelte";
	import IngresosVsGastos from "./Reportes/IngresosVsGastos.svelte";
	import PrestamosVsEndeudamiento from "./Reportes/PrestamosVsEndeudamiento.svelte";

    // Riesgos vs Endeudamiento
    let riestos = $state({})

    function handleRiesgos() {
        fetch(`${PathBackend}/monitoreo/get-reporte2`, {
            method: 'GET',
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {

                let rie = {
                    labels: ['Préstamos de alto riesgo', 'Préstamos regulares', 'Clientes en mora'],
                    datasets: [{
                        data: [data.total_mayor_10k, data.total_menor_10k, data.total_saldo_mayor_0],
                        backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56'],
                    }],
                }

                riestos = rie
                // ingresos = sal
                // console.log(data)

            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    // Ingresos Vs Gastos
    let ingresos = $state({})
    

    function handleIngressos() {
        fetch(`${PathBackend}/monitoreo/get-reporte1`, {
            method: 'GET',
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            
            let sal = {
                labels: data.labels,
                datasets: [
                    { label: 'Ingresos', data: data.datasets[0].data, backgroundColor: '#36A2EB' },
                    { label: 'Gastos', data: data.datasets[1].data, backgroundColor: '#FF6384' },
                ],
            }

            ingresos = sal
            // console.log(sal)
        })
        .catch(er => { alert(er) })
    }

    // Desempeño
    let desempenio = $state({})

    function handleDesempenio() {
        fetch(`${PathBackend}/monitoreo/get-reporte3`, {
            method: 'GET',
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {

                let des = {
                    labels: ['Accesibilidad', 'Facilidad de requisitos', 'Costos', 'Servicios', 'Satisfacción'],
                    datasets: [{
                        label: 'Evaluación',
                        data: [data.accesibilidad, data.facilidad, data.costos, data.servicios, data.satisfaccion],
                        backgroundColor: 'rgba(75, 192, 192, 0.2)',
                        borderColor: 'rgba(75, 192, 192, 1)',
                    }],
                }

                desempenio = des
            }
            // let sal = {
            //     labels: data.labels,
            //     datasets: [
            //         { label: 'Ingresos', data: data.datasets[0].data, backgroundColor: '#36A2EB' },
            //         { label: 'Gastos', data: data.datasets[1].data, backgroundColor: '#FF6384' },
            //     ],
            // }

            // ingresos = sal
            console.log(data)
        })
        .catch(er => { alert(er) })
    }

    // Crecimiento de cartera de clientes y prestamos
    // let cartera = {
    //     labels: ['2020', '2021', '2022', '2023'],
    //     datasets: [
    //         { label: 'Cartera de Clientes', data: [20, 30, 50, 70], borderColor: '#36A2EB', tension: 0.4 },
    //         { label: 'Volumen de Préstamos', data: [10, 20, 40, 60], borderColor: '#FF6384', tension: 0.4 },
    //     ],
    // }

    onMount(() => { 
        handleIngressos()
        handleRiesgos() 
        handleDesempenio()
    })
</script>

<svelte:head>
	<title>Reportes</title>
</svelte:head>
<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Reportes</h1>
</div>
<div class="grid grid-cols-2 gap-6 p-6">
    <!-- Sección Retiros, Depósitos, Bloqueos -->
    <div class="border rounded-lg p-4 bg-white shadow-md max-h-54">
        <h3 class="text-lg font-bold mb-4 text-center">Exposición de riesgos vs endeudamiento</h3>
        <PrestamosVsEndeudamiento data={riestos} />
    </div>
    
    <!-- Tabla de Alertas -->
    <div class="border rounded-lg p-4 bg-white shadow-md max-h-54">
        <h3 class="text-lg font-bold mb-4 text-center">Ingresos vs Gastos</h3>
        <IngresosVsGastos data={ingresos} />
    </div>
</div>
<div class="grid grid-cols-2 gap-6 p-6">
    <!-- Tabla de Roles -->
    <div class="border rounded-lg p-4 bg-white shadow-md">
        <h3 class="text-lg font-bold mb-4 text-center">Desempeño institucional</h3>
        <DesempenoLaboral data={desempenio} />
    </div>

    <!-- Tabla de Usuarios Eliminados -->
    <!-- <div class="border rounded-lg p-4 bg-white shadow-md">
        <h3 class="text-lg font-bold mb-4 text-center">Crecimiento de cartera de clientes y préstamos</h3>
        <CrecimientoVsPrestamo data={cartera} />
    </div> -->
</div>