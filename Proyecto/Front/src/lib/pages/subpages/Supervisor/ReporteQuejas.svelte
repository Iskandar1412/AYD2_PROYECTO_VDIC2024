<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";

    let quejas = $state([]);

    function handleObtainQuejas() {
        fetch(`${PathBackend}/quejasEncuestas/quejas`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal server error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                quejas = data.data
                console.log(data)
            } else {
                throw new Error('Error en la obtención de datos')
            }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => {
        handleObtainQuejas()
    })
</script>

<svelte:head>
	<title>Registro de Quejas</title>
</svelte:head>
<h1 class="text-2xl font-bold mb-6">Registro de Quejas</h1>
<div class="mx-auto">
    
    <!-- Tabla -->
    {#if quejas}
        <table class="table-auto w-full border-collapse border border-gray-300">
            <thead class="bg-gray-200">
                <tr>
                    <th class="border px-4 py-2 bg-white text-center">No. Cuenta</th>
                    <th class="border px-4 py-2 bg-white text-center">Fecha</th>
                    <th class="border px-4 py-2 bg-white text-center">Tipo Queja</th>
                    <th class="border px-4 py-2 bg-white text-center">Detalle Queja</th>
                </tr>
            </thead>
            <tbody>
                {#each quejas as queja, index}
                    <tr>
                        <td class="border px-4 py-2 text-center">{queja.numero_cuenta}</td>
                        <td class="border px-4 py-2 text-center">{queja.fecha.split(' ')[0]}</td>
                        <td class="border px-4 py-2 text-center">{queja.categoria}</td>
                        <td class="border px-4 py-2 text-justify">{queja.detalle}</td>
                    </tr>
                {/each}
            </tbody>
        </table> 
    {/if}

</div>

<style>
</style>
