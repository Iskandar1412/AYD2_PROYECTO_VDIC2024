<script>
	import { PathBackend } from "../../../stores/host";

    let noCuenta = $state();
    let tipoCuenta = $state();  
    
    function realizarSolicitud() {
        fetch(`${PathBackend}/gestion/cuenta/dolares`, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ cuenta: Number(noCuenta), tipo: tipoCuenta })
		})
		.then(res => {
			if(!res.ok) {
				throw new Error('Error en la solicitud')
			}
			return res.json()
		})
        .then(data => {
            console.log(data)
            if(data.message.status === "success") {
                alert(data.message.message)
                noCuenta = null
                tipoCuenta = null
            } else { throw new Error('Error, puede que la cuenta ya tenga activa la aceptación de dolares o no se encuentra') }
        })
        .catch(er => {
            alert(er)
        })
    }
</script>

<svelte:head>
	<title>Permitir Dolares</title>
</svelte:head>

<div class="flex flex-col">
    <div class="flex justify-between items-center mb-8">
        <h1 class="text-2xl font-bold text-gray-800">Permitir Dolares en Cuenta</h1>
        <button
            onclick={realizarSolicitud}
            class="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 focus:outline-none"
            disabled={!noCuenta || noCuenta === 0 || !tipoCuenta}
        >
            Realizar Solicitud
        </button>
    </div>

    <div class="flex justify-center gap-8 items-center">
        <div class="text-center">
            <label for="input-cuental" class="block text-lg font-semibold mb-2 text-gray-700">
                Número de cuenta
            </label>
            <input
                id="input-cuental"
                type="number"
                bind:value={noCuenta}
                placeholder="Ingrese número de cuenta"
                class="p-2 border border-gray-300 rounded-md w-80 text-center focus:ring focus:ring-indigo-300"
            />
        </div>
    
        <div class="text-center">
            <label for="tipo-cuenta" class="block text-lg font-semibold mb-2 text-gray-700">
                Tipo de cuenta
            </label>
            <select
                id="tipo-cuenta"
                bind:value={tipoCuenta}
                class="p-2 border border-gray-300 rounded-md w-80 text-center focus:ring focus:ring-indigo-300"
            >
                <option value="">Seleccione tipo</option>
                <option value="monetaria">Monetario</option>
                <option value="ahorro">Ahorro</option>
            </select>
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