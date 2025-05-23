<script>
	import { user } from "../../../stores/auth";
	import { PathBackend } from "../../../stores/host";
	import { generacionPDF } from "../../../utils/GeneracionPDF";

    let opcionBusquedaCliente = $state("cui");
    let buscarInput = $state();
    let prestamos = $state([]);
    let selectedPrestamo = $state(null);
    let montoSaldar = $state();
    let mostrarTabla = $state(false); 
	let cuentaOb = $state();
	let cuiFull = $state(false);

    function buscarPrestamosDeudor() {
        mostrarTabla = true;
        prestamos = [];


        fetch(`${PathBackend}/prestamos/obtener-prestamos/${buscarInput}`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error("Internal server error")
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                cuentaOb = data.message.cuenta
                prestamos = data.message.prestamos
                console.log(data.message)
            }
        })
        .catch(er => {
            alert(er)
        })
    }


    function handlePagar(prestamo) {
        selectedPrestamo = prestamo;
        montoSaldar = prestamo.monto - prestamo.pagado;
    }

    function realizarPago() {
        if (selectedPrestamo) {
            let jsonS = {
                monto: montoSaldar,
                cuenta: cuentaOb.cuenta_id,
                prestamo: selectedPrestamo.prestamo_id,
                encargado: $user.cui
            }
            
            fetch(`${PathBackend}/prestamos/pago-prestamo`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(jsonS)
            })
            .then(res => {
                if(!res.ok) throw new Error('Error en la busqueda')
                return res.json()
            })
            .then(data => {
                if(data.message.status === 'success') {
                    alert(data.message.message)
                    buscarPrestamosDeudor()
                    generacionPDF(data.message, $user, "Pago Pestamo", cuentaOb.cuenta_id, montoSaldar)
                    console.log(data)
                } else {
                    throw new Error('Error en el pago')
                }
            })
            .catch(er => {
                alert(er)
            })
            .finally(() => {
                selectedPrestamo = null
                montoSaldar = null
            })
        } else {
            alert("Seleccione un préstamo y especifique un monto para pagar.");
        }
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

<svelte:head>
	<title>Pago Prestamos</title>
</svelte:head>
<!-- Contenido Principal -->
<div class="p-6">
    <!-- Header -->
    <div class="flex justify-between items-center mb-12">
        <h2 class="text-2xl font-bold">Pago Préstamos</h2>
        <button
            onclick={realizarPago}
            class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 button-buscar-deudor"
            disabled={(!montoSaldar || montoSaldar === 0)}
        >
            Pago Préstamo
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
            onclick={buscarPrestamosDeudor}
            disabled={(opcionBusquedaCliente === 'cui' && (!cuiFull)) || (opcionBusquedaCliente === 'cuenta' && (!buscarInput))}
            class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 w-1/4"
        >
            Buscar
        </button>
    </div>

    <!-- Tabla de Préstamos -->
    {#if mostrarTabla}
        {console.log(prestamos)}
        {#if prestamos.length > 0}
            <!-- Tabla con Resultados -->
            <div class="w-full overflow-y-auto mb-6" style="max-height: 400px;">
                <table class="table-auto w-full border-collapse border border-gray-300">
                    <thead class="bg-gray-600 text-white">
                        <tr>
                            <th class="border px-4 py-2">CUI</th>
                            <th class="border px-4 py-2">No. Cuenta</th>
                            <th class="border px-4 py-2">Tipo Préstamo</th>

                            <th class="border px-4 py-2">Saldo</th>
                            <th class="border px-4 py-2">Plazo (M)</th>
                            <th class="border px-4 py-2">Pagado</th>
                            <th class="border px-4 py-2">No. Pres</th>
                            <th class="border px-4 py-2">Pagar</th>
                        </tr>
                    </thead>
                    <tbody>
                        {#each prestamos as prestamo}
                            <tr>
                                <td class="bg-gray-300 border px-4 py-2">{cuentaOb.cui}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cuentaOb.cuenta_id}</td>
                                <td class="bg-gray-300 border px-4 py-2">{prestamo.tipo_prestamo}</td>
                                <td class="bg-gray-300 border px-4 py-2">Q. {prestamo.saldo}</td>
                                <td class="bg-gray-300 border px-4 py-2">{prestamo.plazo_meses}</td>
                                <td class="bg-gray-300 border px-4 py-2">Q. {prestamo.total_pagado}</td>
                                <td class="bg-gray-300 border px-4 py-2">{prestamo.prestamo_id}</td>
                                <td class="bg-gray-300 border px-4 py-2 text-center">
                                    <button
                                        onclick={() => handlePagar(prestamo)}
                                        class="px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600"
                                        disabled={prestamo.saldo === 0}
                                    >
                                        Pagar
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

    <!-- Monto Saldar -->
    {#if selectedPrestamo}
        <div class="text-center">
            <h3 class="text-lg font-semibold mb-2">Monto Saldar: PRESS-{selectedPrestamo.prestamo_id}</h3>
            <input
                type="number"
                bind:value={montoSaldar}
                class="p-2 border rounded w-1/4 mb-4"
            />
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
