<script>
	import { PathBackend } from "../../../stores/host";

    let numeroTarjeta = $state();
    let tipoTarjeta = $state('');
    let preguntaSeguridad = $state('');
    let respuestaSeguridad = $state('');
    let motivoBloqueo = $state('');

    function RealizarGestion() {
        let jsonToSend = {
            tarjeta: Number(numeroTarjeta),
            titular: '',
            tipo: tipoTarjeta,
            pregunta: preguntaSeguridad,
            respuesta: respuestaSeguridad,
            motivo: motivoBloqueo,
        }
        
        fetch(`${PathBackend}/gestion/bloqueo-tarjeta`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(jsonToSend)
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                alert('Tarjeta Bloqueada exitosamente')
            } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
        .finally(() => {
            numeroTarjeta = null;
            tipoTarjeta = '';
            preguntaSeguridad = '';
            respuestaSeguridad = '';
            motivoBloqueo = '';
        })
    }
</script>

<svelte:head>
	<title>Bloqueo Tarjeta</title>
</svelte:head>

<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Bloqueo de tarjeta</h1>
    <button
        onclick={RealizarGestion}
        class="px-4 py-2 bg-blue-500 text-white font-semibold rounded hover:bg-blue-600"
        disabled={(!numeroTarjeta || numeroTarjeta <= 0) || !tipoTarjeta || !preguntaSeguridad || !motivoBloqueo}
    >
        Bloqueo Tarjeta
    </button>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto">
    <div class="flex flex-col">
        <label for="numero-tarjeta" class="text-lg font-semibold mb-2 text-gray-700">
            Número de Tarjeta
        </label>
        <input
            id="numero-tarjeta"
            type="number"
            bind:value={numeroTarjeta}
            placeholder="Ingrese número de tarjeta"
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        />
    </div>

    <div class="flex flex-col">
        <label for="tipo-tarjeta" class="text-lg font-semibold mb-2 text-gray-700">
            Tipo de Tarjeta
        </label>
        <select
            id="tipo-tarjeta"
            bind:value={tipoTarjeta}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione tipo</option>
            <option value="credito">Crédito</option>
            <option value="debito">Débito</option>
        </select>
    </div>

    <div class="col-span-2 flex flex-col">
        <label for="pregunta-seguridad" class="text-lg font-semibold mb-2 text-gray-700">
            Pregunta de Seguridad
        </label>
        <select
            id="pregunta-seguridad"
            bind:value={preguntaSeguridad}
            class="p-2 border border-gray-300 rounded-md mb-2 focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione pregunta</option>
            <option value="mascota">Nombre de Mascota</option>
            <option value="comida">Comida Favorita</option>
            <option value="color">Color Favorito</option>
        </select>
        <input
            type="text"
            bind:value={respuestaSeguridad}
            placeholder="Ingrese su respuesta"
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        />
    </div>

    <div class="col-span-2 flex flex-col">
        <label for="motivo-bloqueo" class="text-lg font-semibold mb-2 text-gray-700">
            Motivo de Bloqueo
        </label>
        <select
            id="motivo-bloqueo"
            bind:value={motivoBloqueo}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione motivo</option>
            <option value="robo">Robo</option>
            <option value="perdida">Pérdida</option>
            <option value="fraude">Fraude</option>
        </select>
    </div>
</div>

<style lang="scss">
    div {
        button {
            &:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
        }
    }
</style>