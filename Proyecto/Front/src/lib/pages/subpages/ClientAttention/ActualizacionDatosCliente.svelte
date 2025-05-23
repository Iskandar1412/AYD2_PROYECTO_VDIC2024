<script>
	import { PathBackend } from "../../../stores/host";
	import { calcularEdad } from "../../../utils/GeneracionPass";

    let opcionBusquedaCliente = $state("cui");
    let buscarInput = $state();
    let clientes = $state([]);
    let selectedCliente = $state(null);
    let mostrarTabla = $state(false); 
	let cuiFull = $state(false);
    let cuentaTemp = $state();
    let correoModificar = $state();
    let direccionModificar = $state();
    let telefonoModificar = $state();
    let telefonoFull = $state(false);

    function buscarClienteCheck() {
        mostrarTabla = true;
        clientes = [];

        const input = Number(buscarInput);
        fetch(`${PathBackend}/gestion/cuenta/${input}`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la obtención de informacion')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {
                // console.log(data)
                clientes = [data]
                cuentaTemp = data.cuenta_id
            } else {
                throw new Error('Error en la busqueda de cliente')
            }
        })
        .catch(er => {
            alert(er)
        })
    }

    function realizarCambios() {
        // console.log({telefono: telefonoModificar, direccion: direccionModificar, correo: correoModificar})
        fetch(`${PathBackend}/gestion/actualizar-datos`, {
            method: 'PUT',
            headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
                cuenta: Number(cuentaTemp),
                telefono: Number(telefonoModificar),
                direccion: direccionModificar,
                correo: correoModificar
            })
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la obtención de informacion')
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {

                alert('Datos modificados')
                buscarClienteCheck()
                buscarInput = null
                cuiFull = false
                cuentaTemp = null
                correoModificar = null
                direccionModificar = null
                telefonoModificar = null
                telefonoFull = false
                selectedCliente = null
            } else {
                throw new Error('Error en la actualización')
            }
            
        })
        .catch(er => {
            alert(er)
        })
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

    function handleModificarCliente(cliente) {
        selectedCliente = cliente;
        correoModificar = cliente.correo;
        telefonoModificar = cliente.telefono;
        direccionModificar = cliente.direccion;
    }

    function handleInputTelefono(event) {
		const value = event.target.value;
        telefonoModificar = value.slice(0, 8);
    
        if (value.length < 8) {
        telefonoFull = false;
        } else if (value.length === 8) {
            telefonoFull = true;
        }
	}

	function handleClearInput() {
		buscarInput = '';
		cuiFull = false;
	}
</script>

<svelte:head>
	<title>Actualizacíon Datos Clientes</title>
</svelte:head>
<!-- Contenido Principal -->
<div class="">
    <!-- Header -->
    <div class="flex justify-between items-center mb-12">
        <h2 class="text-2xl font-bold">Datos de Cliente</h2>
        <button
            onclick={realizarCambios}
            class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 button-buscar-deudor"
            disabled={!telefonoFull || !direccionModificar || !correoModificar}
        >
            Modificar Datos
        </button>
    </div>

    <!-- Selector y Input de búsqueda -->
    <div class="flex items-center mb-6 gap-4">
        <select
            bind:value={opcionBusquedaCliente}
            class="p-2 border rounded w-1/4"
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
            class="p-2 border rounded w-2/4"
        />

        <button
            onclick={buscarClienteCheck}
            disabled={(opcionBusquedaCliente === 'cui' && (!cuiFull)) || (opcionBusquedaCliente === 'cuenta' && (!buscarInput))}
            class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 w-1/4"
        >
            Buscar
        </button>
    </div>

    <!-- Tabla de Préstamos -->
    {#if mostrarTabla}
        {#if Array.isArray(clientes)}
            <!-- Tabla con Resultados -->
            <div class="w-full overflow-y-auto mb-6" style="max-height: 400px;">
                <table class="table-auto w-full border-collapse border border-gray-300">
                    <thead class="bg-gray-600 text-white">
                        <tr>
                            <th class="border px-4 py-2">CUI</th>
                            <th class="border px-4 py-2">Nombres</th>
                            <th class="border px-4 py-2">Apellidos</th>
                            <th class="border px-4 py-2">Edad</th>
                            <th class="border px-4 py-2">Correo</th>
                            <th class="border px-4 py-2">Direccion</th>
                            <th class="border px-4 py-2">Teléfono</th>
                            <th class="border px-4 py-2">Género</th>
                            <th class="border px-4 py-2">Modificar Datos</th>
                        </tr>
                    </thead>
                    <tbody>
                        {#each clientes as cliente}
                            <tr>
                                <td class="bg-gray-300 border px-4 py-2">{cliente.cui}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cliente.nombres}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cliente.apellidos}</td>
                                <td class="bg-gray-300 border px-4 py-2">{calcularEdad(cliente.fecha_nac)}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cliente.correo}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cliente.direccion}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cliente.telefono}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cliente.genero}</td>
                                <td class="bg-gray-300 border px-4 py-2 text-center">
                                    <button
                                        onclick={() => handleModificarCliente(cliente)}
                                        class="px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600"
                                    >
                                        Actualizar
                                    </button>
                                </td>
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

    {#if selectedCliente}
        <div class="text-center">
            <h3 class="text-lg font-semibold mb-4">
                Modificar Cliente: {selectedCliente.nombres}
            </h3>
        
            <!-- Teléfono -->
            <div class="mb-4">
                <label for="telefono" class="block text-gray-700 font-medium mb-1">
                    Teléfono
                </label>
                <input
                    id="telefono"
                    type="number"
                    bind:value={telefonoModificar}
                    oninput={handleInputTelefono}
                    placeholder="Ingrese nuevo teléfono"
                    class="p-2 border rounded w-1/2 focus:ring focus:ring-indigo-300"
                />
            </div>
        
            <!-- Dirección -->
            <div class="mb-4">
                <label for="direccion" class="block text-gray-700 font-medium mb-1">
                    Dirección
                </label>
                <input
                    id="direccion"
                    type="text"
                    bind:value={direccionModificar}
                    placeholder="Ingrese nueva dirección"
                    class="p-2 border rounded w-1/2 focus:ring focus:ring-indigo-300"
                />
            </div>
        
            <!-- Correo Electrónico -->
            <div class="mb-4">
                <label for="correo" class="block text-gray-700 font-medium mb-1">
                    Correo Electrónico
                </label>
                <input
                    id="correo"
                    type="email"
                    bind:value={correoModificar}
                    placeholder="Ingrese nuevo correo"
                    class="p-2 border rounded w-1/2 focus:ring focus:ring-indigo-300"
                />
            </div>
        </div>
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
