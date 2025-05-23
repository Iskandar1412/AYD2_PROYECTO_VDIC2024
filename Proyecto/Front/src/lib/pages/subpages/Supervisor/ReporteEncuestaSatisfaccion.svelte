<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";

    let encuestas = $state([]);

    function handleObtainEncuestas() {
        fetch(`${PathBackend}/quejasEncuestas/encuestas`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal server error')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {
                encuestas = data.data
                console.log(data)
            } else {
                throw new Error('Error en la obtención de datos')
            }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => {
        handleObtainEncuestas()
    })
</script>

<svelte:head>
	<title>Encuestas de Satisfacción</title>
</svelte:head>
<h1 class="text-2xl font-bold mb-6">Encuestas de Satisfacción</h1>
<div class="mx-auto">
    
    <!-- Tabla -->
    {#if encuestas}
        <table class="table-auto w-full border-collapse border border-gray-300">
            <thead class="bg-gray-200">
                <tr>
                    <th class="border px-4 py-2 bg-white text-center">No. Cuenta</th>
                    <th class="border px-4 py-2 bg-white text-center">Fecha</th>
                    <th class="border px-4 py-2 bg-white text-center">¿Cuán accesible considera que es este servicio, producto o atención al cliente?</th>
                    <th class="border px-4 py-2 bg-white text-center">¿Cuán claros y fáciles de cumplir le parecen los requisitos necesarios?</th>
                    <th class="border px-4 py-2 bg-white text-center">¿Qué tan razonables considera los costos, comisiones o limitaciones asociados?</th>
                    <th class="border px-4 py-2 bg-white text-center">¿Qué tan fácil le resulta utilizar nuestros servicios en sucursal?</th>
                    <th class="border px-4 py-2 bg-white text-center">¿Qué tan probable es que recomiende este servicio, producto o atención a otras personas?</th>
                </tr>
            </thead>
            <tbody>
                {#each encuestas as encuesta, index}
                    <tr>
                        <td class="border px-4 py-2 text-center">{encuesta.cuenta === 0 ? 'N/A' : encuesta.cuenta}</td>
                        <td class="border px-4 py-2 text-center">{encuesta.fecha_realizacion}</td>
                        <td class="border px-4 py-2 text-center">{encuesta.res_1}</td>
                        <td class="border px-4 py-2 text-center">{encuesta.res_2}</td>
                        <td class="border px-4 py-2 text-center">{encuesta.res_3}</td>
                        <td class="border px-4 py-2 text-center">{encuesta.res_4}</td>
                        <td class="border px-4 py-2 text-center">{encuesta.res_5}</td>
                    </tr>
                {/each}
            </tbody>
        </table> 
    {/if}

</div>

<style>
</style>
