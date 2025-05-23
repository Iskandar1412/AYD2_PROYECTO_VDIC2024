<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../../stores/host";

    let servicios = $state([]);

    function obtenerServicios() {
        fetch(`${PathBackend}/monitoreo/get-solicitudes`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                servicios = data.solicitudes
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => { obtenerServicios() })

    function aprobarServicio(cuenta) {
        fetch(`${PathBackend}/gestion/aprob-cancelacion`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id_cancelacion: cuenta.cancelacion_id, estado: 'aceptado', justificacion: '' })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                alert('Servicio Cancelado')
                obtenerServicios()
                // servicios = data.solicitudes
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
    }

    function rechazarServicio(cuenta) {
        fetch(`${PathBackend}/gestion/aprob-cancelacion`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id_cancelacion: cuenta.cancelacion_id, estado: 'rechazado', justificacion: '' })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                alert('Solicitud Rechazada')
                obtenerServicios()
                // servicios = data.solicitudes
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
    }
</script>


{#if servicios}
<table class="table-auto w-full border-collapse border border-gray-300">
    <thead class="bg-gray-200">
        <tr>
            <th class="border px-4 py-2">No. Cuenta</th>
            <th class="border px-4 py-2">Servicio Cancelar</th>
            <th class="border px-4 py-2">Motivo</th>
            <th class="border px-4 py-2">Fecha</th>
            <th class="border px-4 py-2">Acciones</th>
        </tr>
    </thead>
    <tbody>
        {#each servicios as servicio}
            <tr>
                <td class="border px-4 py-2">{servicio.cuenta}</td>
                <td class="border px-4 py-2">{servicio.tipo_servicio}</td>
                <td class="border px-4 py-2">{servicio.motivo_cancelacion}</td>
                <td class="border px-4 py-2">{`${servicio.fecha}`.split(' ')[0]}</td>
                <td class="border px-4 py-2 text-center">
                    <button
                        class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-400 disabled:cursor-not-allowed"
                        onclick={() => aprobarServicio(servicio)}
                        disabled={servicio.problemas}
                    >
                        Aprobar
                    </button>
                    <button
                        class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
                        onclick={() => rechazarServicio(servicio)}
                    >
                        Rechazar
                    </button>
                </td>
            </tr>
        {/each}
    </tbody>
</table>
{/if}