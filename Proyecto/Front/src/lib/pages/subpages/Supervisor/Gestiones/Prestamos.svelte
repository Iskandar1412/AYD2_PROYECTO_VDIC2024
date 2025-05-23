<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../../stores/host";

    let solicitudesPrestamo = $state([]);

    function ObtenerPrestamo() {
        fetch(`${PathBackend}/prestamos/get-pendprestamos`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                solicitudesPrestamo = data.message.prestamos
            } else { throw new Error('Error en la obtención de prestamos') }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => { ObtenerPrestamo() })

    function imprimirPapeleria(papeleria) {
        const link = document.createElement('a');
        link.href = papeleria.papeleria;
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    function aceptarSolicitud(index, prestamo) {
        fetch(`${PathBackend}/prestamos/aprobacion-prestamo`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id_prestamo: prestamo.prestamo_id, estado: 'aceptado', justificacion: '' })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                console.log(data)
                alert('Solicitud aceptada')
                ObtenerPrestamo()
            } else { throw new Error('Error la operación') }
        })
        .catch(er => { alert(er) })
    }

    function rechazarSolicitud(index, prestamo) {
        fetch(`${PathBackend}/prestamos/aprobacion-prestamo`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id_prestamo: prestamo.prestamo_id, estado: 'rechazado', justificacion: prestamo.motivoRechazo })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                console.log(data)
                alert('Solicitud rechazada exitosamente')
                ObtenerPrestamo()
            } else { throw new Error('Error la operación') }
        })
        .catch(er => { alert(er) })
    }
</script>

<table class="table-auto w-full border-collapse border border-gray-300">
    <thead class="bg-gray-200">
        <tr>
            <th class="border px-4 py-2 text-center">No. Cuenta</th>
            <th class="border px-4 py-2 text-center">Pres. ID</th>
            <th class="border px-4 py-2 text-center">Tipo de Préstamo</th>
            <th class="border px-4 py-2 text-center">Monto</th>
            <th class="border px-4 py-2 text-center">Plazo</th>
            <th class="border px-4 py-2 text-center">Papelería</th>
            <th class="border px-4 py-2 text-center">Motivo Rechazo</th>
            <th class="border px-4 py-2 text-center">Acciones</th>
        </tr>
    </thead>
    <tbody>
        {#each solicitudesPrestamo as solicitud, index}
            <tr>
                <td class="border px-4 py-2 text-center">{solicitud.cuenta_id}</td>
                <td class="border px-4 py-2 text-center">{solicitud.prestamo_id}</td>
                <td class="border px-4 py-2 text-center">{solicitud.tipo_prestamo}</td>
                <td class="border px-4 py-2 text-center">{solicitud.saldo}</td>
                <td class="border px-4 py-2 text-center">{solicitud.plazo_meses}</td>
                <td class="border px-4 py-2 text-center">
                    <button
                        class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                        onclick={() => imprimirPapeleria(solicitud)}
                    >
                        Visualizar
                    </button>
                </td>
                <td class="border px-4 py-2 text-center">
                    <input
                        type="text"
                        class="p-2 border rounded w-full"
                        placeholder="Motivo del rechazo"
                        bind:value={solicitud.motivoRechazo}
                    />
                </td>
                <td class="border px-4 py-2 text-center">
                    <div class="flex justify-center gap-2">
                        <button
                            class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
                            onclick={() => aceptarSolicitud(index, solicitud)}
                        >
                            Aceptar
                        </button>
                        <button
                            class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed"
                            onclick={() => rechazarSolicitud(index, solicitud)}
                            disabled={!solicitud.motivoRechazo}
                        >
                            Rechazar
                        </button>
                    </div>
                </td>
            </tr>
        {/each}
    </tbody>
</table>

<style>
    table {
        width: 100%;
    }
</style>
