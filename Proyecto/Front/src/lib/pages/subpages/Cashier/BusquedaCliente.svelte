<script>
	import { PathBackend } from '../../../stores/host';
	import { calcularEdad } from '../../../utils/GeneracionPass';

	let buscarPor = $state('cui');
	let inputBusqueda = $state();
	let usuario = $state(null);
	let mostrarTransacciones = $state(false);
	let mensajeError = $state('');
	let cuiFull = $state(false);
	let datosUsuarios = $state([]);

	async function buscarUsuario() {
		mensajeError = '';
        usuario = null;
        mostrarTransacciones = false;

        if (!inputBusqueda) {
            mensajeError = 'Por favor, ingrese un valor para buscar.';
            return;
        }

        try {
            const res = await fetch(`${PathBackend}/gestion/cuenta/${inputBusqueda}`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                },
            });

            if (!res.ok) { 
                throw new Error('Error en la solicitud');
            }

            const data = await res.json();
			console.log(data)
            datosUsuarios = [data];

            usuario = datosUsuarios.find(
                (u) =>
                    (buscarPor === 'cui' && u.cui === inputBusqueda) ||
                    (buscarPor === 'numeroCuenta' && u.cuenta_id.toString() === inputBusqueda)
            );

            if (!usuario) {
                mensajeError = 'Usuario no encontrado.';
            }

        } catch (err) {
            console.log(err);
        }
	}

	function obtenerTransaccionesOrdenadas() {
		return usuario ? [...usuario.transacciones].sort((a, b) => a.trans_id - b.trans_id) : [];
	}

	function handleInput(event) {
		const value = event.target.value;
		if (buscarPor === 'cui' && value.length > 13) {
			inputBusqueda = value.slice(0, 13);
		} else if (buscarPor === 'numeroCuenta') {
			inputBusqueda = value;
		}
		if (value.length < 13 && buscarPor === 'cui') {
			cuiFull = false;
		} else if (value.length === 13 && buscarPor === 'cui') {
			cuiFull = true;
		}
	}

	function handleClearInput() {
		inputBusqueda = '';
		cuiFull = false;
	}
</script>

<svelte:head>
	<title>Busqueda Clientes</title>
</svelte:head>
<div class="gap-6 mb-6">
	<div class="flex gap-4 mb-6">
		<!-- Selector de búsqueda -->
		<select
			bind:value={buscarPor}
			class="p-2 rounded border border-gray-300 focus:ring focus:ring-indigo-200"
			onchange={handleClearInput}
		>
			<option value="cui">Buscar por CUI</option>
			<option value="numeroCuenta">Buscar por Número de Cuenta</option>
		</select>

		<input
			type="number"
			bind:value={inputBusqueda}
			oninput={handleInput}
			placeholder="Ingrese el valor a buscar"
			class="p-2 rounded border border-gray-300 flex-1 focus:ring focus:ring-indigo-200"
		/>

		<button
			onclick={buscarUsuario}
			class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 button-buscar-cliente"
			disabled={(buscarPor === 'cui' && !cuiFull) ||
				(buscarPor === 'numeroCuenta' && !inputBusqueda)}
		>
			Buscar
		</button>
	</div>

	{#if mensajeError}
		<div class="p-4 bg-red-100 text-red-700 rounded mb-6">
			{mensajeError}
		</div>
	{/if}

	{#if usuario}
		<div class="p-4 bg-gray-100 rounded shadow mb-6">
			<h3 class="text-xl font-bold">Información del Usuario</h3>
			<p><strong>Nombre:</strong> {usuario.nombres} {usuario.apellidos}</p>
			<p><strong>CUI:</strong> {usuario.cui}</p>
			<p><strong>Edad:</strong> {calcularEdad(usuario.fecha_nac)}</p>
			<p><strong>Número de Cuenta:</strong> {usuario.cuenta_id}</p>
			<p><strong>Correo:</strong> {usuario.correo}</p>
			<p><strong>Tipo de Cuenta:</strong> {usuario.tipo}</p>
			<p><strong>Saldo Actual:</strong> Q{usuario.saldo}</p>
			<p>
				<strong>Fecha del Saldo más Reciente:</strong>
				{usuario.ultima_transaccion}
			</p>
			<button
				onclick={() => (mostrarTransacciones = !mostrarTransacciones)}
				class="mt-4 px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600"
			>
				{#if mostrarTransacciones}
					Ocultar Transacciones
				{/if}
				{#if !mostrarTransacciones}
					Ver Transacciones
				{/if}
			</button>
		</div>

		{#if mostrarTransacciones}
			<!-- {#if usuario.transacciones && usuario.transacciones.length > 0} -->
			{#if Array.isArray(usuario.transacciones)}
				<div class="overflow-x-auto">
					<table class="table-auto w-full bg-white rounded shadow">
						<thead class="bg-gray-200">
							<tr>
								<th class="px-4 py-2">ID</th>
								<th class="px-4 py-2">Tipo</th>
								<th class="px-4 py-2">Fecha</th>
								<th class="px-4 py-2">Monto</th>
								<!-- <th class="px-4 py-2">Encargado</th> -->
							</tr>
						</thead>
						<tbody>
							{#each obtenerTransaccionesOrdenadas() as transaccion}
								<tr>
									<td class="border px-4 py-2">{transaccion.trans_id}</td>
									<td class="border px-4 py-2">{transaccion.tipo}</td>
									<td class="border px-4 py-2">{transaccion.fecha.split(' ')[0]}</td>
									<td class="border px-4 py-2">Q{transaccion.monto}</td>
									<!-- <td class="border px-4 py-2">{transaccion.encargado}</td> -->
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			{:else}
				<p class="text-gray-500 text-center py-4">
					Este usuario no tiene transacciones registradas.
				</p>
			{/if}
		{/if}
	{/if}
</div>

<style>
	div {
		div {
			.button-buscar-cliente:disabled {
				opacity: 0.5;
				cursor: not-allowed;
			}
		}
	}
</style>
