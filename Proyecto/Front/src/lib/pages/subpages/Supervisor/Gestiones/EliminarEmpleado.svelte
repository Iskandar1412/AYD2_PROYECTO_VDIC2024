<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../../stores/host";
	import { calcularEdad } from "../../../../utils/GeneracionPass";

    let empleadosSolicitudes = $state([]);

    function handleObtainUsuarios() {
        fetch(`${PathBackend}/monitoreo/getdespidos`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                empleadosSolicitudes = data.despidos;
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => { handleObtainUsuarios() })

    function imprimirJustificacion(justificacion) {
        const link = document.createElement('a');
        link.href = justificacion.link_doc;
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    function aceptarSol(usuario) {
        fetch(`${PathBackend}/monitoreo/habilitar-elim`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cui: usuario.cui })
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                alert('Solicitud Aceptada')
                handleObtainUsuarios()
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    function rechazarSol(usuario) {
        fetch(`${PathBackend}/monitoreo/rechazar-elim`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cui: usuario.cui })
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                alert('Solicitud Rechazada')
                handleObtainUsuarios()
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }
</script>

<table class="table-auto w-full border-collapse border border-gray-300">
    <thead class="bg-gray-200">
        <tr>
            <th class="border px-4 py-2 text-center">User</th>
            <th class="border px-4 py-2 text-center">Nombres</th>
            <th class="border px-4 py-2 text-center">Correo</th>
            <th class="border px-4 py-2 text-center">Edad</th>
            <th class="border px-4 py-2 text-center">Rol</th>
            <th class="border px-4 py-2 text-center">Justificación</th>
            <th class="border px-4 py-2 text-center">Acciones</th>
        </tr>
    </thead>
    <tbody>
        {#each empleadosSolicitudes as empleado, index}
        {#if empleado.hab_elim !== 1}
            <tr>
                <td class="border px-4 py-2 text-center">{empleado.usuario}</td>
                <td class="border px-4 py-2 text-center">{empleado.nombres} {empleado.apellidos}</td>
                <td class="border px-4 py-2 text-center">{empleado.apellidos}</td>
                <td class="border px-4 py-2 text-center">{calcularEdad(empleado.fecha_nac)}</td>
                <td class="border px-4 py-2 text-center">{empleado.rol}</td>
                <td class="border px-4 py-2 text-center">
                    <button
                        class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                        onclick={() => imprimirJustificacion(empleado)}
                    >
                        Ver Justificación
                    </button>
                </td>
                <td class="border px-4 py-2 text-center">
                    <div class="flex justify-center gap-2">
                        <button
                            class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
                            onclick={() => aceptarSol(empleado)}
                        >
                            Aprobar
                        </button>
                        <button
                            class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed"
                            onclick={() => rechazarSol(empleado)}
                        >
                            Rechazar
                        </button>
                    </div>
                </td>
            </tr>
        {/if}
        {/each}
    </tbody>
</table>

<style>
    table {
        width: 100%;
    }
</style>
