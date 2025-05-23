<script>
	import { user } from "../../../stores/auth";
	import { PathBackend } from "../../../stores/host";
	import { generacionPDF } from "../../../utils/GeneracionPDF";

    let buscarInput = $state();
    let tarjetas = $state([]);
    let selectedTarjeta = $state(null);
    let montoSaldar = $state();
    let mostrarTabla = $state(false); 
    let cuentaOb = $state();

    function handlePagar(prestamo) {
        selectedTarjeta = prestamo;
        montoSaldar = prestamo.monto;
    }

    function buscarPrestamos() {
        mostrarTabla = true;
        tarjetas = [];

        fetch(`${PathBackend}/tarjetas/get-tarjetas/${buscarInput}`, {
            method: 'GET'
        })
        .then(res => {
            if (!res.ok) throw new Error('Error en la busqueda')
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                console.log(data)
                cuentaOb = data.message.cuenta
                tarjetas = data.message.tarjetas
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    function realizarPago() {
        if (selectedTarjeta) {
            let jsonS = {
                monto: montoSaldar,
                cuenta: cuentaOb.cuenta_id,
                tarjeta: selectedTarjeta.tarjeta_id,
                encargado: $user.cui
            }
            
            fetch(`${PathBackend}/tarjetas/pagar-tarjeta`, {
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
                    buscarPrestamos()
                    generacionPDF(data.message, $user, "Pago Tarjeta", cuentaOb.cuenta_id, montoSaldar)
                    console.log(data)
                } else {
                    throw new Error('Error en el pago')
                }
            })
            .catch(er => {
                alert(er)
            })
            .finally(() => {
                selectedTarjeta = null
                montoSaldar = null
            })
        } else {
            alert("Seleccione un préstamo y especifique un monto para pagar.");
        }
    }

	function handleInput(event) {
		const value = event.target.value;
        buscarInput = value;
	}
</script>

<svelte:head>
	<title>Pago de Tarjeta</title>
</svelte:head>
<!-- Contenido Principal -->
<div class="p-6">
    <!-- Header -->
    <div class="flex justify-between items-center mb-12">
        <h2 class="text-2xl font-bold">Pago Tarjeta</h2>
        <button
            onclick={realizarPago}
            class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 button-buscar-deudor"
			disabled={(!montoSaldar || montoSaldar === 0)}
        >
            Realizar Transacción
        </button>
    </div>

    <!-- Selector y Input de búsqueda -->
    <div class="flex items-center mb-6 gap-4">
        <input
            type="number"
            placeholder="Ingrese número de cuenta"
            bind:value={buscarInput}
			oninput={handleInput}
            class="p-2 border rounded w-3/4"
        />

        <button
            onclick={buscarPrestamos}
            disabled={!buscarInput}
            class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 w-1/4"
        >
            Buscar
        </button>
    </div>

    <!-- Tabla de Préstamos -->
    {#if mostrarTabla}
        {#if tarjetas.length > 0}
            <div class="w-full overflow-y-auto mb-6" style="max-height: 400px;">
                <table class="table-auto w-full border-collapse border border-gray-300">
                    <thead class="bg-gray-600" style:color="white">
                        <tr>
                            <!-- { tarjeta_id: 6, cuenta: "567890", tipo: 'credito', titular: 'Jose 6', interes: 5, tasa_interes: 2, monto: 125, vigencia: 'activa' } -->
                            <th class="border px-4 py-2">ID Tarjeta</th>
                            <th class="border px-4 py-2">Cuenta</th>
                            <th class="border px-4 py-2">Tipo</th>
                            <th class="border px-4 py-2">Titular</th>
                            
                            <th class="border px-4 py-2">Limite</th>
                            <th class="border px-4 py-2">Vigencia</th>
                            <th class="border px-4 py-2">Vigencia</th>
                            <th class="border px-4 py-2">Pagado</th>
                            <th class="border px-4 py-2"></th>
                        </tr>
                    </thead>
                    <tbody>
                        {#each tarjetas as tarjeta}
                        {#if tarjeta.tipo !== 'debito'}
                            <tr>
                                <td class="bg-gray-300 border px-4 py-2">{tarjeta.tarjeta_id}</td>
                                <td class="bg-gray-300 border px-4 py-2">{cuentaOb.cuenta_id}</td>
                                <td class="bg-gray-300 border px-4 py-2">{tarjeta.tipo}</td>
                                <td class="bg-gray-300 border px-4 py-2">{tarjeta.titular}</td>
                                
                                <td class="bg-gray-300 border px-4 py-2">{tarjeta.limite}</td>
                                <td class="bg-gray-300 border px-4 py-2">{tarjeta.vigencia}</td>
                                <td class="bg-gray-300 border px-4 py-2">{tarjeta.vigencia}</td>
                                <td class="bg-gray-300 border px-4 py-2">{tarjeta.total_pagado}</td>
                                <td class="bg-gray-300 border px-4 py-2 text-center">
                                    <button
                                        onclick={() => handlePagar(tarjeta)}
                                        class="px-3 py-1 bg-emerald-500 text-white rounded hover:bg-emerald-600"
                                    >
                                        Pagar
                                    </button>
                                </td>
                            </tr>
                        {/if}
                        {/each}
                    </tbody>
                </table>
            </div>
        {:else}
            <!-- Mensaje cuando no hay resultados -->
            <p class="text-center text-red-600 font-semibold">
                Cuenta no encontrada
            </p>
        {/if}
    {/if}

    <!-- Monto Saldar -->
    {#if selectedTarjeta}
        <div class="text-center">
            <h3 class="text-lg font-semibold mb-2">Saldar Tarjeta: {selectedTarjeta.tarjeta_id}</h3>
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
            button {
                &:disabled {
                    opacity: 0.5;
                    cursor: not-allowed;
                }
            }
		}
	}
</style>