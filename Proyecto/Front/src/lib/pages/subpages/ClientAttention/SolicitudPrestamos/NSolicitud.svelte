<script>
	import { user } from "../../../../stores/auth";
	import { PathBackend } from "../../../../stores/host";
    let tipoCliente = $state('');
    let fullNumeroCliente = $state(false);
    let numeroCliente = $state();
    let cuentaCancelar = $state('')
    let motivoCancelar = $state()
    let tarjetaCancelar = $state()

    function realizarGestion() {
        let url = cuentaCancelar === 'cuenta' ? `${PathBackend}/gestion/sol-cancelacion-c` :
            `${PathBackend}/gestion/sol-cancelacion-t`

        let JsonToSend = cuentaCancelar === 'cuenta' ?
            { cuenta: Number(numeroCliente), motivo: motivoCancelar, tipo: 'cuenta' } :
            { cuenta: Number(numeroCliente), motivo: motivoCancelar, tipo: 'tarjeta', tarjeta: Number(tarjetaCancelar) }

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(JsonToSend)
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                alert('Solicitud Realizada')
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
        .finally(() => { 
            fullNumeroCliente = null
            tipoCliente = ''
            numeroCliente = null
            cuentaCancelar = ''
            motivoCancelar = null
            tarjetaCancelar = null
        })
    }

    function handleInput(event) {
        const value = event.target.value;

        if (tipoCliente === "identificacion" && value.length > 13) {
            numeroCliente = value.slice(0, 13);
        } else {
            numeroCliente = value;
        }

        if (tipoCliente === 'identificacion' && value.length === 13) {
            fullNumeroCliente = true;
        } else if (value.length < 13 && tipoCliente === 'cuenta') {
            fullNumeroCliente = false
        }
    }

    function limpiarCampo() {
        numeroCliente = null;
    }

    function handleLimpiarCuenta() {
        tarjetaCancelar = null
    }

</script>

<div class="flex items-center mb-6">
    <h2 class="text-xl font-bold px-6 py-2">Nueva Solicitud de Cancelación</h2>
    <div class="ml-auto">
        <button
            onclick={() => {realizarGestion()}}
            class="px-6 py-2 font-bold rounded-md bg-blue-500 text-white hover:bg-blue-600 focus:outline-none button-gestion-dr"
            disabled={
                !tipoCliente || 
                (tipoCliente === 'identificacion' && !fullNumeroCliente) || 
                (tipoCliente === 'cuenta' && !numeroCliente) || 
                (tipoCliente === 'cuenta' && numeroCliente <= 0) || 
                (!cuentaCancelar) || 
                !motivoCancelar || 
                (cuentaCancelar === 'tarjeta' && !tarjetaCancelar) || 
                (cuentaCancelar === 'tarjeta' && tarjetaCancelar <= 0)
            }
        >
            Realizar Gestión
        </button>
    </div>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto">
    <div class="flex flex-col">
        <label for="tipo-dato" class="text-lg font-semibold mb-2 text-gray-700">
            Cuenta o Identificación
        </label>
        <select
            id="tipo-dato"
            bind:value={tipoCliente}
            onchange={limpiarCampo}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300 mb-4"
        >
            <option value="">Seleccione tipo</option>
            <option value="cuenta">Número de Cuenta</option>
            <option value="identificacion">Identificación</option>
        </select>
        <input
            id="numero-cliente"
            type="number"
            bind:value={numeroCliente}
            oninput={handleInput}
            placeholder={tipoCliente === "anonimo" ? "Cliente Anonimo" : `Ingrese ${tipoCliente.toLowerCase() || 'dato'}`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
            disabled={!tipoCliente}
        />
    </div>

    <div class="flex flex-col">
        <label for="rapidez-eficiencia" class="text-lg font-semibold mb-2 text-gray-700">
            Servicio Cancelar
        </label>
        <select
            id="rapidez-eficiencia"
            bind:value={cuentaCancelar}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300 mb-4"
            onchange={handleLimpiarCuenta}
        >
            <option value="">Seleccione</option>
            <option value="cuenta">Cuenta</option>
            <option value="tarjeta">Tarjeta</option>
        </select>
        <input
            id="numero-cliente"
            type="number"
            bind:value={tarjetaCancelar}
            placeholder={`Ingrese no. tarjeta`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
            disabled={!cuentaCancelar || cuentaCancelar === 'cuenta'}
        />
    </div>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto mt-8 mb-8">
    <div class="flex flex-col">
        <label for="motivo" class="text-lg font-semibold mb-2 text-gray-700">
            Motivo
        </label>
        <input
            id="motivo"
            type="text"
            bind:value={motivoCancelar}
            placeholder={`Motivo de Cancelación`}
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