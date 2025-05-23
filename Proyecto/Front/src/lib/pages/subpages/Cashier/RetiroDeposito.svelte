<script>
	import { user } from "../../../stores/auth";
	import { PathBackend } from "../../../stores/host";
	import { generacionPDF } from "../../../utils/GeneracionPDF";

	let gestion = $state('deposito');
	let numeroCuenta = $state();
	let monto = $state();
	let tipoCuenta = $state('');
	let tipoMoneda = $state('');

	async function realizarGestion() {
        let url = gestion === 'deposito' ?
            `${PathBackend}/gestion/deposito` : 
            `${PathBackend}/gestion/retiro`

        let contentJson = gestion === 'deposito' ? 
            { monto: Number(monto),  cuenta: Number(numeroCuenta), deposito: 1, moneda: tipoMoneda === 'quetzal' ? 1 : 2, cui_encargado: Number($user.cui), tipoCuenta: tipoCuenta } : 
            { monto: Number(monto),  cuenta: Number(numeroCuenta), retiro: 1, moneda: tipoMoneda === 'quetzal' ? 1 : 2, cui_encargado: Number($user.cui), tipoCuenta: tipoCuenta }

        fetch(url , {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(contentJson)
        })
        .then(res => {
            if(!res.ok) {
                throw new Error('Eror en gestion')
            }
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                // console.log(data.message, $user, gestion === 'deposito' ? 'Deposito' : 'Retiro', numeroCuenta, monto)
                generacionPDF(data.message, $user, gestion === 'deposito' ? 'Deposito' : 'Retiro', numeroCuenta, monto)
                alert('Petición aceptada')
                // numeroCuenta = null
                // monto = null
                // tipoCuenta = ''
                // tipoMoneda = ''
            } else {
                throw new Error('Error en la petición, cuenta no existente')
                // generacionPDF(data)
                // console.log('asfasdf')
            }
        })
        .catch(err => {
            console.log(err)
            alert(err)
        })
	}

    function handleChangeOption() {
        numeroCuenta = ''
        tipoCuenta = ''
        monto = ''
        tipoMoneda = ''
    }
</script>

<svelte:head>
	<title>Deposito/Retiro</title>
</svelte:head>
<div class="flex items-center mb-6">
    <!-- Botón de opción Retiro/Depósito -->
    <div class="flex items-center">
        <button
            aria-label="Button-Option-Retiro-Deposito"
            class="w-20 h-8 flex items-center rounded-full cursor-pointer shadow-md"
            onclick={() => {
                handleChangeOption(),
                (gestion = gestion === 'deposito' ? 'retiro' : 'deposito')
            }}
            class:bg-green-500={gestion === 'deposito'}
            class:bg-yellow-500={gestion === 'retiro'}
        >
            <div
                class="w-6 h-6 rounded-full bg-white shadow transform transition-transform duration-300"
                class:translate-x-12={gestion === 'retiro'}
                class:translate-x-1={gestion === 'deposito'}
            ></div>
        </button>
    </div>

    <!-- Texto de la gestión seleccionada -->
    <div class="ml-4 text-lg font-semibold">
        Gestión seleccionada:
        <span class={gestion === 'deposito' ? 'text-green-600' : 'text-yellow-600'}>
            {gestion === 'deposito' ? 'Depósito' : 'Retiro'}
        </span>
    </div>

    <!-- Botón Realizar Gestión alineado a la derecha -->
    <div class="ml-auto">
        <button
            onclick={() => realizarGestion()}
            class="px-6 py-2 font-bold rounded-md bg-blue-500 text-white hover:bg-blue-600 focus:outline-none button-gestion-dr"
            disabled={
                (!numeroCuenta || numeroCuenta === 0) || (monto === 0 || !monto) || (!tipoCuenta || tipoCuenta === '') || (!tipoMoneda || tipoMoneda === '')
            }
        >
            Realizar Gestión
        </button>
    </div>
</div>
<div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
            <label for="numeroCuenta" class="block text-lg font-medium text-gray-700">
                Número de cuenta
            </label>
            <input
                id="numeroCuenta"
                type="number"
                bind:value={numeroCuenta}
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            />
        </div>

        <div>
            <label for="tipoCuenta" class="block text-lg font-medium text-gray-700">
                Tipo de Cuenta
            </label>
            <select
                id="tipoCuenta"
                bind:value={tipoCuenta}
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            >
                <option value="">Seleccionar</option>
                <option value="monetaria">Monetaria</option>
                <option value="ahorro">Ahorro</option>
            </select>
        </div>
        
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
            <label for="monto" class="block text-lg font-medium text-gray-700">
                {#if gestion === 'deposito'}
                    Monto a Depositar
                {:else if gestion === 'retiro'}
                    Monto a Retirar
                {/if}
            </label>
            <input
                id="monto"
                type="number"
                bind:value={monto}
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            />
        </div>

        <div>
            <label for="tipoMoneda" class="block text-lg font-medium text-gray-700">
                {#if gestion === 'deposito'}
                    Moneda a Depositar
                {:else if gestion === 'retiro'}
                    Moneda a Retirar
                {/if}
            </label>
            <select
                id="tipoMoneda"
                bind:value={tipoMoneda}
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 text-base p-3"
            >
                <option value="">Seleccionar</option>
                <option value="quetzal">Quetzales</option>
                <option value="dolar">Dolares</option>
            </select>
        </div>

        
    </div>
</div>



<style lang="scss">
    div {
        div {

            .button-gestion-dr:disabled {
                opacity: 0.4;
                cursor: not-allowed;
            }
        }
    }
</style>