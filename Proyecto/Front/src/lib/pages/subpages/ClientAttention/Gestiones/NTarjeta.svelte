<script>
	import { user } from "../../../../stores/auth";
	import { PathBackend } from "../../../../stores/host";

    let numerocuenta = $state()
    let tipotarjeta = $state('')
    let limiteCredito = $state()
    function realizarGestion() {
        let JsonEnviar = {
            cuenta: Number(numerocuenta),
            tipo: tipotarjeta,
            limite: tipotarjeta === 'credito' ? limiteCredito : 0,
            encargado: $user.cui 
        }

        fetch(`${PathBackend}/tarjetas/solicitarTarjeta`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(JsonEnviar)
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                alert("Solicitud de tarjeta enviada")
                console.log(data)
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
        .finally(() => { window.location.reload; })
    }
</script>

<div class="flex items-center mb-6">
    <h2 class="text-xl font-bold px-6 py-2">Crear Tarjeta</h2>
    <div class="ml-auto">
        <button
            onclick={() => {realizarGestion()}}
            class="px-6 py-2 font-bold rounded-md bg-blue-500 text-white hover:bg-blue-600 focus:outline-none button-gestion-dr"
            disabled={!numerocuenta || numerocuenta <= 0 || !tipotarjeta || (tipotarjeta === 'credito' && !limiteCredito) || (tipotarjeta === 'credito' && limiteCredito <= 0)}
        >
            Realizar Gestión
        </button>
    </div>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto">
    <div class="flex flex-col">
        <label for="tipo-dato" class="text-lg font-semibold mb-2 text-gray-700">
            Número de Cuenta
        </label>
        <input
            id="numero-cliente"
            type="number"
            bind:value={numerocuenta}
            placeholder={`Ingrese número de cuenta`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
        />
    </div>

    <div class="flex flex-col">
        <label for="rapidez-eficiencia" class="text-lg font-semibold mb-2 text-gray-700">
            Tipo Tarjeta
        </label>
        <select
            id="rapidez-eficiencia"
            bind:value={tipotarjeta}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione</option>
            <option value="credito">Crédito</option>
            <option value="debito">Débito</option>
        </select>
    </div>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto">
    <div class="flex flex-col">
        <label for="tipo-dato" class="text-lg font-semibold mb-2 text-gray-700">
            Límite de Cŕedito
        </label>
        <input
            id="numero-cliente"
            type="number"
            bind:value={limiteCredito}
            disabled={!tipotarjeta || tipotarjeta === 'debito'}
            placeholder={`Límite de Crédito`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
        />
    </div>

    <div class="flex flex-col">
        <label for="rapidez-eficiencia" class="text-lg font-semibold mb-2 text-gray-700">
            Empleado Encargado
        </label>
        <input
            id="numero-cliente"
            type="number"
            disabled
            placeholder={`${$user.nombres} ${$user.apellidos}`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
        />
    </div>
</div>

<style lang="scss">
    .button-gestion-dr {
        &:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    }
</style>