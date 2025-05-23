<script>
	import { user } from "../../../stores/auth";
	import { PathBackend } from "../../../stores/host";
	import { generacionPDF } from "../../../utils/GeneracionPDF";

    let cuentaUsuario = $state();
    let servicioSeleccionado = $state("");
    let montoAPagar = $state();
    // agua 1 luz 2 tele 3 inter 4
    // <option value="agua">Agua</option>
    // <option value="luz">Luz</option>
    // <option value="telefono">Teléfono</option>
    // <option value="internet">Internet</option>
    let servicioInt = $state()
    $effect(() => {
        if(servicioSeleccionado === 'agua') servicioInt = 1
        if(servicioSeleccionado === 'luz') servicioInt = 2
        if(servicioSeleccionado === 'telefono') servicioInt = 3
        if(servicioSeleccionado === 'internet') servicioInt = 4
    })

    function realizarGestion() {
        // console.log({cui_enc: $user.cui, cod_servicio: servicioInt ,monto: montoAPagar, cuenta: cuentaUsuario});
        let jsonS = {
            monto: montoAPagar,
            cuenta: cuentaUsuario,
            servicio: servicioInt,
            cui_encargado: $user.cui
        }

        fetch(`${PathBackend}/transacciones/pagar-servicio`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(jsonS)
        })
        .then(res => {
            // console.log(res)
            if(!res.ok) { throw new Error('Error en la transaccion') }
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                alert('Servicio pagado exitosamente')
                generacionPDF(data.message, $user, `Pago Servicio ${servicioSeleccionado}`, cuentaUsuario, montoAPagar)
                servicioSeleccionado = ''
                montoAPagar = null
                cuentaUsuario = null
            } else { throw new Error('Error') }
        })
        .catch(err => {
            console.log(err)
        })
    }
</script>

<svelte:head>
	<title>Pago de Servicios</title>
</svelte:head>
<div class="p-6">
    <div class="flex justify-between items-center mb-6">
        <!-- Texto alineado a la izquierda -->
        <h2 class="text-2xl font-bold text-gray-800">Pago de Servicios</h2>
    
        <!-- Botón alineado a la derecha -->
        <button
            onclick={realizarGestion}
            class="px-6 py-2 font-bold rounded-md bg-blue-500 text-white hover:bg-blue-600 focus:outline-none button-pago-servicio"
            disabled={(!cuentaUsuario || cuentaUsuario === 0) || (!servicioSeleccionado || servicioSeleccionado === '') || (!montoAPagar || montoAPagar === 0) }
        >
            Realizar Gestión
        </button>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
            <label for="cuentaUsuario" class="block text-lg font-medium text-gray-700">
                Cuenta del usuario
            </label>
            <input
                id="cuentaUsuario"
                type="number"
                bind:value={cuentaUsuario}
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            />
        </div>

        <div>
            <label for="servicioSeleccionado" class="block text-lg font-medium text-gray-700">
                Servicio
            </label>
            <select
                id="servicioSeleccionado"
                bind:value={servicioSeleccionado}
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            >
                <option value="">Seleccionar</option>
                <option value="agua">Agua</option>
                <option value="luz">Luz</option>
                <option value="telefono">Teléfono</option>
                <option value="internet">Internet</option>
            </select>
        </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
        <div>
            <label for="montoAPagar" class="block text-lg font-medium text-gray-700">
                Monto a pagar
            </label>
            <input
                id="montoAPagar"
                type="number"
                bind:value={montoAPagar}
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            />
        </div>

        <div>
            <label for="nombreUsuario" class="block text-lg font-medium text-gray-700">
                Encargado
            </label>
            <input
                id="nombreUsuario"
                type="text"
                value={$user.nombres}
                readonly
                class="mt-1 block w-full bg-gray-100 cursor-not-allowed rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            />
        </div>
    </div>
</div>

<style>
	div {
		div {
			.button-pago-servicio:disabled {
				opacity: 0.5;
				cursor: not-allowed;
			}
		}
	}
</style>