<script>
	import { navigate } from "svelte-routing";
	import { PathBackend } from "../../../stores/host";

    let numeroCliente = $state();
    let fullNumeroCliente = $state(false);
    let tipoQueja = $state('');
    let detallesQueja = $state('');
    let tipoDato = $state('');

    function handleSendEmail() {
        const mailOptions = {
            from: 'no-reply@proyect1activate.com',
            to: 'XXXXX@gmail.com',
            subject: 'Registro de Quejas',
            html: `<p>Categoria: <strong>${tipoQueja}</strong></p><br/>
            <p>${tipoDato}: <strong>${numeroCliente}</strong></p><br/>
            <p>Detalles: <strong>${detallesQueja}</strong></p><br/>`
        };

        fetch(`${PathBackend}/mail/email`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(mailOptions)
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {
                alert('Correo enviado al usuario')
                console.log(data)
            } else { throw new Error('Error al enviar correo') }
        })
        .catch(er => {
            alert(er)
        })
        .finally(() => {
            window.location.reload
        })
    }

    function registrarQueja() {
        let quejaToSend = {
            detalle: detallesQueja,
            categoria: tipoQueja,
            cui: tipoDato === 'identificacion' ? Number(numeroCliente) : 0,
            cuenta: tipoDato === 'cuenta' ? Number(numeroCliente) : 0
        };
        
        fetch(`${PathBackend}/quejasEncuestas/regqueja`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(quejaToSend)
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {
                console.log(data)
                alert('Queja subida correctamente')
                handleSendEmail()
                window.location.reload;
                navigate('/home')
            } else {
                throw new Error('Error en registrar queja')
            }
        })
        .catch(er => {
            alert(er)
        })
        // alert("Queja registrada correctamente. Revisa la consola para más detalles.");
    }

    function handleInput(event) {
        const value = event.target.value;

        if (tipoDato === "identificacion" && value.length > 13) {
            numeroCliente = value.slice(0, 13);
        } else {
            numeroCliente = value;
        }

        if (tipoDato === 'identificacion' && value.length === 13) {
            fullNumeroCliente = true;
        } else if (value.length < 13 && tipoDato === 'cuenta') {
            fullNumeroCliente = false
        }
    }

    function limpiarCampo() {
        numeroCliente = '';
    }
</script>

<svelte:head>
    <title>Registro de Quejas</title>
</svelte:head>

<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Registro de Quejas</h1>
    <button
        onclick={registrarQueja}
        class="px-4 py-2 bg-red-500 text-white font-semibold rounded hover:bg-red-600"
        disabled={((tipoDato === 'cuenta' && (!numeroCliente || numeroCliente <= 0)) || (tipoDato === 'identificacion' && !fullNumeroCliente) || !tipoDato) || !tipoQueja || !detallesQueja.trim()}
    >
        Registrar Queja
    </button>
</div>

<div class="grid grid-cols-1 gap-6 w-3/5 m-auto">
    <div class="flex flex-col">
        <label for="tipo-dato" class="text-lg font-semibold mb-2 text-gray-700">
            Cuenta o Identificación
        </label>
        <select
            id="tipo-dato"
            bind:value={tipoDato}
            onchange={limpiarCampo}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300 mb-4"
        >
            <option value="">Seleccione tipo</option>
            <option value="cuenta">Número de Cuenta</option>
            <option value="identificacion">Identificación</option>
        </select>
    
        <label for="numero-cliente" class="text-lg font-semibold mb-2 text-gray-700">
            {tipoDato || 'Número de Cuenta o Identificación'}
        </label>
        <input
            id="numero-cliente"
            type="number"
            bind:value={numeroCliente}
            oninput={handleInput}
            placeholder={`Ingrese ${tipoDato.toLowerCase() || 'dato'}`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
            disabled={!tipoDato || tipoDato === 'anonimo'}
        />
    </div>

    <div class="flex flex-col">
        <label for="tipo-queja" class="text-lg font-semibold mb-2 text-gray-700">
            Tipo de Queja
        </label>
        <select
            id="tipo-queja"
            bind:value={tipoQueja}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
        >
            <option value="">Seleccione tipo</option>
            <option value="Servicio">Servicio</option>
            <option value="Producto">Producto</option>
            <option value="Atención al cliente">Atención al cliente</option>
        </select>
    </div>

    <div class="flex flex-col">
        <label for="detalles-queja" class="text-lg font-semibold mb-2 text-gray-700">
            Detalles
        </label>
        <textarea
            id="detalles-queja"
            bind:value={detallesQueja}
            placeholder="Describa los detalles de su queja..."
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
            rows="5"
        ></textarea>
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
