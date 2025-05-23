<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";

    let copias = $state([]);

    async function obtenerBackups() {
        fetch(`${PathBackend}/administracion/getbackups`, {
            method: 'GET',
            headers: {
					'Content-Type': 'application/json',
				},
        })
        .then(res => {
            if(!res.ok) {
                // throw new Error('Error en obtención de copias')
            }
            return res.json()
        })
        .then(data => {
            // console.log(data)
            copias = data.message;
        })
        .catch(er => {
            alert(er)
        })
    }

    onMount(() => {
        obtenerBackups()
    })

    async function procesarMensaje(json) {
        const mensaje = json.message;

        const nombreArchivo = mensaje.substring(mensaje.lastIndexOf('/') + 1);

        // console.log(json.message, nombreArchivo.split('.')[0])
        fetch(`${PathBackend}/administracion/registrarBackup`, {
            method: 'POST',
            headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({ nombre: nombreArchivo.split('.')[0].replace("\"", ''), link: json.message})
        })
        .then(res => {
            if(!res.ok) {
                throw new Error('Error al subir la copia')
            }
            return res.json()
        })
        .then(async (data) => {
            // console.log(data)
            if(data.message.status === 'success') await obtenerBackups()
        })
        .catch(er => {
            alert(er)
        })
        // return {
        //     nombre: nombre,
        //     fecha: fechaSinExtension
        // };
    }

    function handleCrearCopiaSeguridad() {
        fetch(`${PathBackend}/administracion/backup-db`, {
                method: 'GET',
            }
        )
        .then(res => {
            if(!res.ok) {
                throw new Error('Error al generar copia de seguridad')
            }
            return res.json()
        })
        .then(async (data) => {
            if(data.message) {
                await procesarMensaje(data)
            }
        })
        .catch(er => {
            alert(er)
        })
        // procesarMensaje({
        //     "message": "https://XXXXX.s3.amazonaws.com/backup_20241222071310883.sql"
        // })
    }

    function handleDownloadCopiaSeguridad(copia) {
        // alert(copia.link_backup)
        const link = document.createElement(`a`)
        link.href = copia.link_backup;
        link.target = '_blank';
        link.download = '';
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
    }
</script>

<svelte:head>
	<title>Copias de Seguridad</title>
</svelte:head>
<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Copias de Seguridad</h1>
    <button
        onclick={handleCrearCopiaSeguridad}
        class="px-4 py-2 bg-blue-500 text-white font-semibold rounded hover:bg-blue-600"
    >
        Copia de Seguridad
    </button>
</div>
<div class="w-3/5 mx-auto">
    {#if !Array.isArray(copias)}
        <p class="text-center">No hay copias</p>
    {:else if Array.isArray(copias) && copias.length > 0}
        <table class="table-auto w-full border-collapse border border-gray-300">
            <thead class="bg-gray-200">
                <tr>
                    <th class="border px-4 py-2 bg-white">Nombre</th>
                    <th class="border px-4 py-2 bg-white">Fecha</th>
                    <th class="border px-4 py-2 bg-white">Download</th>
                </tr>
            </thead>
            <tbody>
                {#each copias as copia, index}
                    <tr>
                        <td class="border px-4 py-2">Copia {copia.id}</td>
                        <td class="border px-4 py-2 text-center">{copia.fecha}</td>
                        <td class="border px-4 py-2 align-center">
                            <div class="flex justify-center gap-2">
                                <button
                                    onclick={() => handleDownloadCopiaSeguridad(copia)}
                                    class="px-4 py-1 bg-teal-500 text-white rounded hover:bg-teal-600 button-ok-rol"
                                >
                                    Download
                                </button>
                            </div>
                        </td>
                    </tr>
                {/each}
            </tbody>
        </table>
    {/if}
</div>