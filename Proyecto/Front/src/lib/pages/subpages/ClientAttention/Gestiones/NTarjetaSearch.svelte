<script>
	import { PathBackend } from "../../../../stores/host";

    let buscarInput = $state()
    let mostrarTabla = $state(false)
    let usuarios = $state([])

    function buscarUsuario() {
        mostrarTabla = true;
        usuarios = [];

        fetch(`${PathBackend}/tarjetas/getsol-tarjetas/${buscarInput}`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.message[0].status === 'success') {
                usuarios = data.message
            } else { throw new Error('Error en la solicitud') }
            // console.log(data.message[0])
        })
        .catch(er => { alert(er) })
        .finally(() => { window.location.reload; })
    }

</script>

<!-- Contenido Principal -->
<div class="p-6">
    <!-- Selector y Input de búsqueda -->
    <div class="flex items-center mb-6 gap-4">
        <input
            type="number"
            placeholder={'Ingrese número de cuenta'}
            bind:value={buscarInput}
            class="p-2 border rounded w-3/4"
        />

        <button
            onclick={buscarUsuario}
            disabled={!buscarInput || buscarInput <= 0}
            class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 w-1/4"
        >
            Buscar
        </button>
    </div>

    <!-- Tabla de Préstamos -->
    {#if mostrarTabla}
        {#if usuarios.length > 0}
            <!-- Tabla con Resultados -->
            <div class="w-full overflow-y-auto mb-6" style="max-height: 400px;">
                <table class="table-auto w-full border-collapse border border-gray-300">
                    <thead class="bg-gray-600 text-white">
                        <tr>
                            <th class="border px-4 py-2">No. Cuenta</th>
                            <th class="border px-4 py-2">Tipo Tarjeta</th>
                            <th class="border px-4 py-2">Límite de Crédito</th>
                            <th class="border px-4 py-2">Encargado</th>
                            <th class="border px-4 py-2">Fecha</th>
                            <th class="border px-4 py-2">Estado Solicitud</th>
                        </tr>
                    </thead>
                    <tbody>
                        {#each usuarios as usuario}
                            <tr>
                                <td class="bg-gray-300 border px-4 py-2">{usuario.numero_cuenta}</td>
                                <td class="bg-gray-300 border px-4 py-2">{usuario.tipo_tarjeta}</td>
                                <td class="bg-gray-300 border px-4 py-2">{usuario.tipo_tarjeta === 'credito' ? `Q. ` + usuario.limite : "N/A"}</td>
                                <td class="bg-gray-300 border px-4 py-2">{usuario.encargado}</td>
                                <td class="bg-gray-300 border px-4 py-2">{usuario.fecha.split(' ')[0]}</td>
                                <td class="bg-gray-300 border px-4 py-2">{usuario.estado_solicitud}</td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </div>
        {:else}
            <!-- Mensaje cuando no hay resultados -->
            <p class="text-center text-red-600 font-semibold">
                Usuario o cuenta no encontrada
            </p>
        {/if}
    {/if}
</div>

<style>
    div {
        div {
            button:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
        }
    }
</style>
