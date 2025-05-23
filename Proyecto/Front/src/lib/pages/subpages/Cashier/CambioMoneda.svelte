<script>
	import { user } from "../../../stores/auth";
	import { PathBackend } from "../../../stores/host";
	import { generacionCambioMoneda } from "../../../utils/GeneracionPDF";
	
    let cantidadQ = $state();       // Valor ingresado en Cantidad Q
    let cambioDolar = $state();     // Valor calculado para el Cambio en $
    let nocuenta = $state()

    const tipoCambio = 7.79;          // Tasa de cambio Q -> $

    // Función para calcular el cambio en $
    function calcularCambio() {
        if (cantidadQ && (cantidadQ > 0)) {
            cambioDolar = (cantidadQ / tipoCambio).toFixed(2); // Redondeo a 2 decimales
        } else {
            cambioDolar = 0;
        }
    }

    function realizarSolicitud() {
        fetch(`${PathBackend}/gestion/cambio-moneda`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ cuenta: nocuenta, monto: cantidadQ })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                alert(data.message.message)
                generacionCambioMoneda(data.message, $user, "Cambio Moneda", nocuenta, cantidadQ)
                nocuenta = null
                cantidadQ = null
                cambioDolar = null
            } else { throw new Error('Error en la petición') }
        })
        .catch(er => { alert(er) })
        // alert(`Se solicitó un cambio de Q${cantidadQ} a $${cambioDolar}`);
    }
</script>

<svelte:head>
	<title>Cambio Moneda</title>
</svelte:head>
<div class="flex flex-col p-6">
    <!-- Título -->
    <div class="flex justify-between items-center mb-8">
        <h1 class="text-2xl font-bold text-gray-800">Cambio Moneda Quetzal a Dolar</h1>
        <button
            onclick={realizarSolicitud}
            class="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 focus:outline-none"
            disabled={!cantidadQ || cantidadQ <= 0 || !nocuenta || nocuenta <= 0}
        >
            Realizar Solicitud
        </button>
    </div>

    <!-- Inputs -->
    <div class="flex justify-center gap-16 items-center">
        <!-- Input Cantidad Q -->
        <div class="text-center">
            <label for="cuenta-cliente" class="block text-lg font-semibold mb-2 text-gray-700">Numero de cuenta</label>
            <input
                id="cuenta-cliente"
                type="number"
                bind:value={nocuenta}
                placeholder="Ingrese número de cuenta"
                class="p-2 border border-gray-300 rounded-md w-54 text-center focus:ring focus:ring-indigo-300"
            />
        </div>
        
        <div class="text-center">
            <label for="input-quetzal" class="block text-lg font-semibold mb-2 text-gray-700">Cantidad Q</label>
            <input
                id="input-quetzal"
                type="number"
                bind:value={cantidadQ}
                oninput={calcularCambio}
                placeholder="Ingrese cantidad Q"
                class="p-2 border border-gray-300 rounded-md w-54 text-center focus:ring focus:ring-indigo-300"
            />
        </div>
        <!-- Input Cambio en $ (Deshabilitado) -->
        <div class="text-center">
            <label for="input-dolar" class="block text-lg font-semibold mb-2 text-gray-700">Cantidad $</label>
            <input
                id="input-dolar"
                type="number"
                bind:value={cambioDolar}
                disabled
                class="p-2 border border-gray-300 rounded-md w-54 text-center focus:ring focus:ring-indigo-300"
            />
        </div>
        
    </div>
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