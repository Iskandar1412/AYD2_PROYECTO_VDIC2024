<script>
	import { PathBackend } from "../../../../stores/host";

    let opcionBusquedaCliente = $state("cui")
    let buscarInput = $state()
	let cuiFull = $state(false)
    let mostrarTabla = $state(false)
    let usuarios = $state([])

    function buscarUsuario() {
        mostrarTabla = true;
        usuarios = [];

        // const input = buscarInput !== undefined && buscarInput !== null ? String(buscarInput).trim() : "";

        // if (input) {
        //     if (opcionBusquedaCliente === "cui") {
        //         usuarios = baseDadeDatos.filter((item) => item.cui === Number(input));
        //     } else if (opcionBusquedaCliente === "cuenta") {
        //         usuarios = baseDadeDatos.filter((item) => item.cuenta_id === Number(input));
        //     }
        // } else {
        //     console.warn("El valor de búsqueda está vacío o inválido.");
        // }
        fetch(`${PathBackend}/gestion/get-sol-cancelacion/${buscarInput}` , {
            method: 'GET',
            // headers: { 'Content-Type': 'application/json' },
            // body: JSON.stringify(JsonToSend)
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                usuarios = data.solicitudes
            } else { throw new Error('Error en la obtención de usuarios') }
        })
        .catch(er => { alert(er) })
    }

    function handleInput(event) {
		const value = event.target.value;
		if (opcionBusquedaCliente === 'cui' && value.length > 13) {
			buscarInput = value.slice(0, 13);
		} else if (opcionBusquedaCliente === 'cuenta') {
			buscarInput = value;
		}
		if (value.length < 13 && opcionBusquedaCliente === 'cui') {
			cuiFull = false;
		} else if (value.length === 13 && opcionBusquedaCliente === 'cui') {
			cuiFull = true;
		}
	}

    function handleClearInput() {
		buscarInput = '';
		cuiFull = false;
	}
</script>

<!-- Contenido Principal -->
<div class="p-6">
    <!-- Selector y Input de búsqueda -->
    <div class="flex items-center mb-6 gap-4">
        <select
            bind:value={opcionBusquedaCliente}
            class="p-2 border rounded w-2/5"
            onchange={handleClearInput}
        >
            <option value="cui">Buscar por CUI</option>
            <option value="cuenta">Buscar por Número de Cuenta</option>
        </select>

        <input
            type="number"
            placeholder={opcionBusquedaCliente === 'cui' ? 'Ingrese CUI' : 'Ingrese número de cuenta'}
            bind:value={buscarInput}
            oninput={handleInput}
            class="p-2 border rounded w-2/5"
        />

        <button
            onclick={buscarUsuario}
            disabled={(opcionBusquedaCliente === 'cui' && (!cuiFull)) || (opcionBusquedaCliente === 'cuenta' && (!buscarInput))}
            class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 w-1/5"
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
                            <th class="border px-4 py-2">Servicio a Cancelar</th>
                            <th class="border px-4 py-2">Motivo</th>
                            <th class="border px-4 py-2">Fecha</th>
                            <th class="border px-4 py-2">Estado Solicitud</th>
                        </tr>
                    </thead>
                    <tbody>
                        {#each usuarios as usuario}
                            <tr>
                                <td class="bg-gray-300 border px-4 py-2 text-center">{usuario.cuenta}</td>
                                <td class="bg-gray-300 border px-4 py-2 text-center">{usuario.tipo}</td>
                                <td class="bg-gray-300 border px-4 py-2 text-center">{usuario.motivo}</td>
                                <td class="bg-gray-300 border px-4 py-2 text-center">{`${usuario.fecha}`.split(' ')[0]}</td>
                                <td class="bg-gray-300 border px-4 py-2 text-center">{usuario.estado}</td>
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
