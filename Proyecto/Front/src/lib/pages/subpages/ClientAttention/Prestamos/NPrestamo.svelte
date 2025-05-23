<script>
	// import { user } from "../../../../stores/auth";
	import { PathBackend } from "../../../../stores/host";
    let tipoCliente = $state('')
    let fullNumeroCliente = $state(false)
    let numeroCliente = $state()
    let tipoPrestamoSolicitado = $state('')
    let montoPrestamo = $state()
    let plazoPago = $state()
    let papeleria = $state(null);
    let papeleriaNombre = $state(null);

    // data.identificador,data.monto,data.plazo,currentDate,data.tipo,data.monto/data.plazo,data.link_papeleria
    function realizarGestion() {
        let JsonEnviar = {
            identificador: Number(numeroCliente),
            link_papeleria: papeleria,
            monto: montoPrestamo,
            plazo: plazoPago,
            tipo: tipoPrestamoSolicitado === 'personal' ? 1 :
            tipoPrestamoSolicitado === 'hipotecario' ? 2 :
            tipoPrestamoSolicitado === 'vehicular' ? 3 : 4 
        }

        fetch(`${PathBackend}/prestamos/sol-prestamo`, {
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
            console.log(data)
            if(data.message.status === 'success') { alert('Solicitud de prestamo enviada') }
            else { throw new Error('Error en la solicitud') }
            // if(data.message.status === 'success') {
            //     alert("Solicitud de tarjeta enviada")
            //     console.log(data)
            // } else { throw new Error('Error en la solicitud') }
        })
        .catch(er => { alert(er) })
        .finally(() => { window.location.reload; })
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

    function handlePapeleriaUpload(event) {
        const file = event.target.files[0];
        if (file && file.type === "application/pdf") {
            const reader = new FileReader();
            reader.onload = () => {
                papeleria = reader.result.toString().split(",")[1];
                // console.log("Archivo PDF en Base64:", papeleria);
            };
            reader.readAsDataURL(file);
        } else {
            alert("Solo se permiten archivos PDF.");
            papeleria = null;
        }
    }

    function limpiarCampo() {
        numeroCliente = '';
    }
</script>

<div class="flex items-center mb-6">
    <h2 class="text-xl font-bold px-6 py-2">Nueva Solicitud de Prestamo</h2>
    <div class="ml-auto">
        <button
            onclick={() => {realizarGestion()}}
            class="px-6 py-2 font-bold rounded-md bg-blue-500 text-white hover:bg-blue-600 focus:outline-none button-gestion-dr"
            disabled={!tipoCliente || (tipoCliente === 'identificacion' && !fullNumeroCliente) || (tipoCliente === 'cuenta' && !numeroCliente) || (tipoCliente === 'cuenta' && numeroCliente <= 0) || (!tipoPrestamoSolicitado) || !montoPrestamo || montoPrestamo <= 0 || !plazoPago || plazoPago <= 0 || !papeleria}
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
            Tipo Prestamo
        </label>
        <select
            id="rapidez-eficiencia"
            bind:value={tipoPrestamoSolicitado}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-indigo-300"
        >
            <option value="">Seleccione</option>
            <option value="personal">Personal</option>
            <option value="hipotecario">Hipotecario</option>
            <option value="vehicular">Vehicular</option>
            <option value="educativo">Educativo</option>
        </select>
    </div>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto mt-8 mb-8">
    <div class="flex flex-col">
        <label for="motivo" class="text-lg font-semibold mb-2 text-gray-700">
            Monto
        </label>
        <input
            id="motivo"
            type="number"
            bind:value={montoPrestamo}
            placeholder={`Ingrese monto`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
        />
    </div>

    <div class="flex flex-col">
        <label for="plazo-pago" class="text-lg font-semibold mb-2 text-gray-700">
            Plazo (Meses)
        </label>
        <input
            id="plazo-pago"
            type="number"
            bind:value={plazoPago}
            placeholder={`Ingrese plazo`}
            class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-red-300"
        />
    </div>
</div>
<div class="grid grid-cols-2 gap-6 w-3/5 m-auto mt-8 mb-8">
    <div class="flex flex-col text-center items-center justify-center">
        <label for="papeleria" class="block text-lg font-medium mb-2 text-gray-700">Subir Papelería (PDF)</label>
        <div id="papeleria" class="w-32 h-32 border-2 border-dashed border-gray-300 rounded flex items-center justify-center mb-4">
            {#if papeleriaNombre}
                <span class="text-sm text-gray-700">{papeleriaNombre}</span>
            {:else}
                <span class="text-gray-400 text-sm">Vista previa</span>
            {/if}
        </div>
        <label
            class="cursor-pointer px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
        >
            Subir papelería
            <input
                type="file"
                accept="application/pdf"
                class="hidden"
                onchange={handlePapeleriaUpload}
            />
        </label>
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