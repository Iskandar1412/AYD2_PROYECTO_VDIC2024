<script>
	import { navigate } from "svelte-routing";
	import { PathBackend } from "../../../stores/host";

    let tipoCliente = $state('');
    let fullNumeroCliente = $state(false);
    let numeroCliente = $state();
    let categoria = $state();
    let pregunta1 = $state('');
    let pregunta2 = $state('');
    let pregunta3 = $state('');
    let pregunta4 = $state('');
    let pregunta5 = $state('');

    function enviarEvaluacion() {

        let valuesToSend = {
            cui: tipoCliente === 'anonimo' ? 0 : tipoCliente === 'identificacion' ? Number(numeroCliente) : 0,
            cuenta: tipoCliente === 'anonimo' ? 0 : tipoCliente === 'cuenta' ? Number(numeroCliente) : 0,
            anonimato: tipoCliente === "anonimo" ? true : false,
            res1: pregunta1,
            res2: pregunta2,
            res3: pregunta3,
            res4: pregunta4,
            res5: pregunta5,
            categoria: categoria, 
        }
        console.log(valuesToSend)

        fetch(`${PathBackend}/quejasEncuestas/regencuesta`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(valuesToSend)
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {
                alert('Encuesta Enviada satisfactoriamente')
                window.location.reload
                navigate('/home')
            } else {
                throw new Error('Error en el envio de la encuesta')
            }
        })
        .catch(er => {
            alert(er)
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
        numeroCliente = '';
    }
</script>

<svelte:head>
    <title>Encuesta de Satisfacción</title>
</svelte:head>

<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Encuesta de Satisfacción</h1>
    <button
        onclick={enviarEvaluacion}
        class="px-4 py-2 bg-blue-500 text-white font-semibold rounded hover:bg-blue-600"
        disabled={
            !tipoCliente ||
            (tipoCliente === "cuenta" && !numeroCliente) ||
            (tipoCliente === 'identificacion' && !fullNumeroCliente) ||
            !pregunta1 || // pregunta 1
            !pregunta2 || // pregunta 2
            !pregunta3 || // pregunta 3
            !pregunta4 || // pregunta 4
            !pregunta5 || // pregunta 5
            !categoria // pregunta 5
        }
    >
        Enviar Evaluación
    </button>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto">
    <div class="flex flex-col">
        <label for="tipo-dato" class="text-lg font-semibold mb-2 text-gray-700">
            Cuenta o Identificación (Opcional)
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
            <option value="anonimo">Anónimo</option>
        </select>
        <input
            id="numero-cliente"
            type="number"
            bind:value={numeroCliente}
            oninput={handleInput}
            placeholder={tipoCliente === "anonimo" ? "Cliente Anonimo" : `Ingrese ${tipoCliente.toLowerCase() || 'dato'}`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
            disabled={!tipoCliente || tipoCliente === 'anonimo'}
        />
    </div>

    <div class="flex flex-col">
        <label for="rapidez-eficiencia" class="text-lg font-semibold mb-2 text-gray-700">
            Categoria a Calificar
        </label>
        <select
            id="rapidez-eficiencia"
            bind:value={categoria}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione</option>
            <option value="atencion">Atención al Cliente</option>
            <option value="servicios">Servicios</option>
            <option value="productos">Productos</option>
        </select>
    </div>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto mt-8">
    <div class="flex flex-col">
        <label for="experiencia-general" class="text-lg font-semibold mb-2 text-gray-700">
            ¿Cuán accesible considera que es este servicio, producto o atención al cliente? 
        </label>
        <select
            id="experiencia-general"
            bind:value={pregunta1}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione</option>
            {#each Array(5).fill().map((_, i) => i + 1) as numero}
                <option value={numero}>{numero}</option>
            {/each}
        </select>
    </div>

    <div class="flex flex-col">
        <label for="rapidez-eficiencia" class="text-lg font-semibold mb-2 text-gray-700">
            ¿Cuán claros y fáciles de cumplir le parecen los requisitos necesarios?
        </label>
        <select
            id="rapidez-eficiencia"
            bind:value={pregunta2}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione</option>
            <option value={1}>Muy difícil</option>
            <option value={2}>Difícil</option>
            <option value={3}>Neutral</option>
            <option value={4}>Fácil</option>
            <option value={5}>Muy fácil</option>
        </select>
    </div>

    <div class="flex flex-col">
        <label for="atencion-cliente" class="text-lg font-semibold mb-2 text-gray-700">
            ¿Qué tan razonables considera los costos, comisiones o limitaciones asociados? 
        </label>
        <select
            id="atencion-cliente"
            bind:value={pregunta3}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione</option>
            {#each Array(5).fill().map((_, i) => i + 1) as numero}
                <option value={numero}>{numero}</option>
            {/each}
        </select>
    </div>

    <div class="flex flex-col">
        <label for="facilidad-uso" class="text-lg font-semibold mb-2 text-gray-700">
            ¿Qué tan fácil le resulta utilizar nuestros servicios en sucursal?
        </label>
        <select
            id="facilidad-uso"
            bind:value={pregunta4}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value={''}>Seleccione</option>
            <option value={1}>Muy difícil</option>
            <option value={2}>Difícil</option>
            <option value={3}>Neutral</option>
            <option value={4}>Fácil</option>
            <option value={5}>Muy fácil</option>
        </select>
    </div>

    <div class="col-span-2 flex flex-col">
        <label for="mejoras-sugeridas" class="text-lg font-semibold mb-2 text-gray-700">
            ¿Qué tan probable es que recomiende este servicio, producto o atención a otras personas?
        </label>
        <select
            id="mejoras-sugeridas"
            bind:value={pregunta5}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value={''}>Seleccione</option>
            <option value={1}>1</option>
            <option value={2}>2</option>
            <option value={3}>3</option>
            <option value={4}>4</option>
            <option value={5}>5</option>
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
