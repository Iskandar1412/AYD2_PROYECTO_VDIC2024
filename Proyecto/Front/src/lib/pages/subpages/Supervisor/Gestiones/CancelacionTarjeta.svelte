<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../../stores/host";

    let tarjetas = $state([]);
    
    function obtenerTarjetas() {
        fetch(`${PathBackend}/tarjetas/get-tarjetaspendientes`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data.message)
            if(data.message.status === 'success') {
                tarjetas = data.message.tarjetas
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => { obtenerTarjetas() })

    function aprobarTarjeta(numero) {
        fetch(`${PathBackend}/tarjetas/aprob-tarjeta`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id_tarjeta: numero.tarjeta_id, justificacion: '', estado: 'aceptado'  })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data.message)
            if(data.message.status === 'success') {
                alert('Tarjeta Aceptada')
                obtenerTarjetas()
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
    }

    function rechazarTarjeta(numero) {
        fetch(`${PathBackend}/tarjetas/aprob-tarjeta`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id_tarjeta: numero.tarjeta_id, justificacion: ' ', estado: 'rechazado'  })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data.message)
            if(data.message.status === 'success') {
                alert('Tarjeta Rechazada')
                obtenerTarjetas()
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
    }
</script>


{#if tarjetas}
<table class="table-auto w-full border-collapse border border-gray-300">
    <thead class="bg-gray-200">
        <tr>
            <th class="border px-4 py-2 text-center">No. Tarjeta</th>
            <th class="border px-4 py-2 text-center">Tipo Tarjeta</th>
            <th class="border px-4 py-2 text-center">Límite Crédito</th>
            <th class="border px-4 py-2 text-center">Nombre Cliente</th>
            <th class="border px-4 py-2 text-center">Fecha</th>
            <th class="border px-4 py-2 text-center">Acciones</th>
        </tr>
    </thead>
    <tbody>
        {#each tarjetas as tarjeta}
            <tr>
                <td class="border px-4 py-2 text-center">{tarjeta.tarjeta_id}</td>
                <td class="border px-4 py-2 text-center">{tarjeta.tipo}</td>
                <td class="border px-4 py-2 text-center">{tarjeta.tipo === 'credito' ? tarjeta.limite : 'N/A'}</td>
                <td class="border px-4 py-2 text-center">{tarjeta.titular}</td>
                <td class="border px-4 py-2 text-center">{`${tarjeta.fecha_solicitud}`.split(' ')[0]}</td>
                <td class="border px-4 py-2 text-center">
                    <button
                        class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-400 disabled:cursor-not-allowed"
                        onclick={() => aprobarTarjeta(tarjeta)}
                        disabled={tarjeta.recordCrediticio === 'Malo'}
                    >
                        Aprobar
                    </button>
                    <button
                        class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
                        onclick={() => rechazarTarjeta(tarjeta)}
                    >
                        Rechazar
                    </button>
                </td>
            </tr>
        {/each}
    </tbody>
</table>
{/if}