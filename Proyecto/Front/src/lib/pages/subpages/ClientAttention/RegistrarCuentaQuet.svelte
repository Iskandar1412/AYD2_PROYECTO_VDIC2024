<script>
	import { navigate } from "svelte-routing";
	import { PathBackend } from "../../../stores/host";
	import { calcularNacimiento } from "../../../utils/GeneracionPass";

    let paginaActual = $state(1);
    let progreso = $state(0);

    let nombre = $state('');
    let apellido = $state('');
    let cui = $state();
    let cuiFull = $state(false);
    let telefono = $state();
    let telefonoFull = $state(false);
    let correo = $state('');
    let edad = $state();
    let direccion = $state();
    let genero = $state('');
    let fotoPreview = $state(null);
    let fotoBase64 = $state(null);
    let tipoCuenta = $state();
    let preguntaSeguridad = $state();
    let respuestaSeguridad = $state();
    let montoApertura = $state();


    function validarPagina1() {
        if(!nombre || !apellido || !cuiFull || !telefonoFull || !correo || (!edad || edad <= 0) || !genero || !fotoPreview || !direccion) return false
        return true
    }

    function validarPagina2() {
        if(!tipoCuenta || (!montoApertura || montoApertura <= 0) || !preguntaSeguridad || !respuestaSeguridad) return false
        return true
    }

    function irSiguientePagina() {
        if (validarPagina1()) {
            paginaActual = 2;
            progreso = 50;
        }
    }

    function regresarPagina() {
        paginaActual = 1;
        progreso = 0;
    }

    async function handlePreguntaSeguridad(id_cuenta_cliente) {
        let variableToSendPaso2 = {
            pregunta: preguntaSeguridad,
            respuesta: respuestaSeguridad,
            id_cuenta: Number(id_cuenta_cliente)
        };

        fetch(`${PathBackend}/gestion/registrar-pr`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(variableToSendPaso2)
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la creación de cuenta')
            return res.json()
        })
        .then(data => {
            // console.log(data)
            if(data.message.status === "success") {
                alert('Cuenta completa creada exitosamente');
                window.location.reload;
                navigate('/home')
            } else {
                throw new Error('Error en la creación de cuenta')
            }
        })
        .catch(er => {
            alert(er)
        })
    }

    async function handleCrearCuenta() {
        let variableToSendPaso2 = {
            cui: Number(cui),
            tipo: tipoCuenta,
            saldo: montoApertura
        };

        fetch(`${PathBackend}/gestion/crear-cuenta`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(variableToSendPaso2)
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la creación de cuenta')
            return res.json()
        })
        .then(data => {
            // console.log(data)
            if(data.message.status === "success") {
                handlePreguntaSeguridad(data.message.cuenta_id)
            } else {
                throw new Error('Error en la creación de cuenta')
            }
        })
        .catch(er => {
            alert(er)
        })
    }

    async function handleSubmit() {
        if (validarPagina2()) {
            progreso = 100;
            setTimeout(() => {
                
                let variableToSendPaso1 = {
                    nombres: nombre,
                    apellidos: apellido,
                    cui: Number(cui),
                    telefono: Number(telefono),
                    direccion: direccion,
                    correo: correo,
                    linkFoto: fotoBase64,
                    fechaNacimiento: calcularNacimiento(edad),
                    genero: genero
                };
                // alert("Formulario enviado correctamente. Revisa la consola.");
                fetch(`${PathBackend}/gestion/cliente`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(variableToSendPaso1)
                })
                .then(res => {
                    if(!res.ok) throw new Error('Error en la solicitud')
                    return res.json()
                })
                .then(data => {
                    // console.log(data)
                    if(data.message.status === 'success') {
                        handleCrearCuenta()
                    } else {
                        throw new Error('Error en la creación de cliente')
                    }
                })
                .catch(er => {
                    alert(er)
                })
            }, 1000); 
        }
    }

    function handleImageUpload(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();

            reader.onload = function (e) {
                const base64String = e.target.result;
                fotoPreview = URL.createObjectURL(file);
                fotoBase64 = base64String;
            };

            reader.readAsDataURL(file);
        }
    }

    function handleInputCUI(event) {
		const value = event.target.value;
			cui = value.slice(0, 13);
		if (value.length < 13) {
			cuiFull = false;
		} else if (value.length === 13) {
			cuiFull = true;
		}
	}

    function handleInputTelefono(event) {
        const value = event.target.value;
			telefono = value.slice(0, 8);
		if (value.length < 8) {
			telefonoFull = false;
		} else if (value.length === 8) {
			telefonoFull = true;
		}
    }
</script>

<svelte:head>
	<title>Registrar Cuenta</title>
</svelte:head>

<div>
    <h1 class="text-3xl font-bold text-gray-800 mb-5">Creación de Cuenta en Quetzales</h1>
</div>
<div class="flex items-center justify-center">
    <div class="form-container">

        <div class="mb-6">
            <p class="text-sm font-medium mb-2">Progreso: {progreso}%</p>
            <div class="w-full bg-gray-200 rounded-full">
                <div
                    class="progress-bar bg-blue-500"
                    style="width: {progreso}%; transition: width 0.5s ease;"
                ></div>
            </div>
        </div>

        {#if paginaActual === 1}
            <h2 class="text-xl font-bold mb-4">Información Personal</h2>
            <div class="grid grid-cols-2 gap-6">
                <input type="text" bind:value={nombre} placeholder="Nombre" class="p-2 border rounded" />
                <input type="text" bind:value={apellido} placeholder="Apellido" class="p-2 border rounded" />
                <input type="number" bind:value={cui} placeholder="CUI" class="p-2 border rounded" oninput={handleInputCUI} />
                <input type="number" bind:value={telefono} placeholder="Teléfono" class="p-2 border rounded" oninput={handleInputTelefono} />
                <input type="text" bind:value={correo} placeholder="Correo" class="p-2 border rounded" />
                <input type="number" bind:value={edad} placeholder="Edad" class="p-2 border rounded" />
                <select bind:value={genero} class="p-2 border rounded">
                    <option value="">Seleccione género</option>
                    <option value="masculino">Masculino</option>
                    <option value="femenino">Femenino</option>
                </select>
                <input type="text" bind:value={direccion} placeholder="Dirección" class="p-2 border rounded" />
            </div>

            <div class="mt-4">
                <label for="photo-div" class="block text-sm font-medium mb-2 text-center">
                    Subir Foto
                </label>
                <div class="flex flex-col items-center" id="photo-div">
                    <div class="image-preview">
                        {#if fotoPreview}
                            <img src={fotoPreview} alt="Foto" class="w-full h-full object-cover rounded" />
                        {:else}
                            <span class="text-gray-400 text-sm">Vista previa</span>
                        {/if}
                    </div>
                    <label for="file-input" class="cursor-pointer mt-2 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
                        Buscar Imagen
                    </label>
                    <input id="file-input" type="file" accept="image/*" onchange={handleImageUpload} class="hidden" />
                </div>
            </div>

            <div class="flex justify-end mt-6">
                <button
                    onclick={irSiguientePagina}
                    disabled={!validarPagina1()}
                    class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:bg-gray-400"
                >
                    Siguiente
                </button>
            </div>
        {/if}

        {#if paginaActual === 2}
            <h2 class="text-xl font-bold mb-4">Información Adicional</h2>
            <div class="grid grid-cols-2 gap-6">
                <div>
                    <!-- ahorro','monetaria -->
                    <label for="tipo-cuenta" class="block text-sm font-medium mb-1">Tipo de cuenta</label>
                    <select id="tipo-cuenta" bind:value={tipoCuenta} class="p-2 border rounded w-full">
                        <option value="">Seleccione tipo</option>
                        <option value="monetaria">Monetaria</option>
                        <option value="ahorro">Ahorro</option>
                    </select>

                    <label for="monto" class="block text-sm font-medium mb-1 mt-2">Monto para abrir cuenta</label>
                    <input
                        id="monto"
                        type="number"
                        bind:value={montoApertura}
                        placeholder="Ingrese monto"
                        class="p-2 border rounded w-full"
                    />
                </div>
            
                <div>
                    <label for="pregunta-seguridad" class="block text-sm font-medium mb-1">Pregunta de Seguridad</label>
                    <select id="pregunta-seguridad" bind:value={preguntaSeguridad} class="p-2 border rounded w-full">
                        <option value="">Seleccione pregunta</option>
                        <option value="mascota">Nombre de Mascota</option>
                        <option value="comida">Comida Favorita</option>
                        <option value="color">Color Favorito</option>
                    </select>
                    
                    <input
                        id="respuesta"
                        type="text"
                        bind:value={respuestaSeguridad}
                        placeholder="Ingrese su respuesta"
                        class="p-2 border rounded w-full mt-4"
                    />
                </div>
            
               
            </div>
            <div class="flex justify-between mt-6">
                <button
                    onclick={regresarPagina}
                    class="px-4 py-2 bg-red-400 text-white rounded hover:bg-red-500"
                >
                    Regresar
                </button>
                <button
                    onclick={handleSubmit}
                    disabled={!validarPagina2()}
                    class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-400 button-submitgo"
                >
                    Submit
                </button>
            </div>
        {/if}
    </div>
</div>

<style>
    .progress-bar {
        height: 20px;
        border-radius: 10px;
    }

    .form-container {
        width: 75%;
        margin: auto;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        padding: 2rem;
    }

    .image-preview {
        width: 150px;
        height: 150px;
        border: 2px dashed #ccc;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #f9fafb;
    }
    
    .button-submitgo:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }     
</style>
