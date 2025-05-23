<script>
	import { PathBackend } from "../../../stores/host";
	import { calcularNacimiento, generarContrasena } from "../../../utils/GeneracionPass";

    let nombres = $state('');
    let apellidos = $state('');
    let edad = $state();
    let dpi = $state();
    let dpiFull = $state(false);
    let correo = $state('');
    let genero = $state('');
    let estadoCivil = $state('');
    let usuario = $state();
    let telefono = $state();
    let telefonoFull = $state(false);

    let fotoPreview = $state(null);
    let fotoBase64 = $state(null);

    let papeleria = $state(null);
    let papeleriaNombre = $state(null);

    function handleImageUpload(event, tipo) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();

            reader.onload = function (e) {
                const base64String = e.target.result;
                if (tipo === 'foto') {
                    fotoPreview = URL.createObjectURL(file);
                    fotoBase64 = base64String;
                }
            };

            reader.readAsDataURL(file);
        }
    }

    function handleSendEmail(pass, f2a) {
        const mailOptions = {
            from: 'no-reply@proyect1activate.com',
            to: correo,
            subject: 'Creación de cuenta',
            html: `<p>Su cuenta fue creada <strong>${usuario}</strong><br/>su contraseña: ${pass}</p>`,
            attachments: [
                {
                    filename: `2FA${usuario}.ayd`, // Nombre del archivo con la extensión deseada
                    content: `${f2a}`, // Contenido dinámico
                },
            ],
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

    async function volverAdmin(usu, pasu) {
        let contraseni2fa = generarContrasena()
        fetch(`${PathBackend}/administracion/crearadmin`, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ cui: usu, fa: contraseni2fa })
		})
        .then(res => {
            if(!res.ok) { throw new Error('Error en la creación') }
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                alert('Usuario Administrador creado exitosamente')
                handleSendEmail(pasu, contraseni2fa)
                // window.location.reload;
            } else {
                throw new Error('Error en volver administrador')
            }
        })
        .catch(err => {
            alert(err)
        }) 
        .finally(() => {
            window.location.reload;
        })
    }
    
    async function crearUsuario() {
        let usuarioTemp = {
            cui: dpi,
            nombres: nombres,
            apellidos: apellidos,
            telefono: telefono,
            fecha_nac: calcularNacimiento(edad),
            correo: correo,
            usuario: usuario,
            password: generarContrasena(),
            genero: genero,
            link_foto: fotoBase64,
            estado_civil: estadoCivil,
            link_papeleria: papeleria,
            link_firma: null,
        };

		fetch(`${PathBackend}/administracion/registrarEmpleado`, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify(usuarioTemp)
		})
		.then(res => {
			if(!res.ok) {
				throw new Error('Error en la solicitud')
			}
			return res.json()
		})
		.then(async (data) => {
            console.log(data)
			if(data.status === 'success') {
                volverAdmin(usuarioTemp.cui, usuarioTemp.password);
                // alert('Usuario creado exitosamente')
                // window.location.reload()
            }
			if(data.status === 'error') {
				throw new Error('Error en la creación de usuario')
			}
			// console.log(data.message)
		})
		.catch(err => {
			alert(err)
		})
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

    function handleInput(event) {
		const value = event.target.value;
        dpi = value.slice(0, 13);
        
		if (value.length < 13 ) {
			dpiFull = false;
		} else if (value.length === 13) {
			dpiFull = true;
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
	<title>Nuevo Administrador de Sistemas</title>
</svelte:head>
<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Crear Administrador de Sistemas</h1>
    <button
        onclick={crearUsuario}
        class="px-4 py-2 bg-blue-500 text-white font-semibold rounded hover:bg-blue-600"
        disabled={
            !nombres || !apellidos || !dpiFull || !correo || !genero || !estadoCivil || !usuario || !telefonoFull ||
            (!edad || edad <= 0) ||  
            !papeleria || 
            !fotoBase64
        }
    >
        Crear Usuario
    </button>
</div>
<div class="w-3/4 m-auto grid gap-8">
    <!-- Primera Fila -->
    <div class="grid grid-cols-5 gap-6 mb-8">
        <div class="flex flex-col">
            <label for="nombres" class="text-lg font-medium text-gray-700 mb-1">Nombres</label>
            <input
                id="nombres"
                type="text"
                bind:value={nombres}
                placeholder="Ingrese nombres"
                class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            />
        </div>
        <div class="flex flex-col">
            <label for="apellidos" class="text-lg font-medium text-gray-700 mb-1">Apellidos</label>
            <input
                id="apellidos"
                type="text"
                bind:value={apellidos}
                placeholder="Ingrese apellidos"
                class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            />
        </div>
        <div class="flex flex-col">
            <label for="edad" class="text-lg font-medium text-gray-700 mb-1">Edad</label>
            <input
                id="edad"
                type="number"
                bind:value={edad}
                placeholder="Ingrese edad"
                class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            />
        </div>
        <div class="flex flex-col">
            <label for="dpi" class="text-lg font-medium text-gray-700 mb-1">DPI</label>
            <input
                id="dpi"
                type="number"
                oninput={handleInput}
                bind:value={dpi}
                placeholder="Ingrese DPI"
                class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            />
        </div>
        <div class="flex flex-col">
            <label for="telefono" class="text-lg font-medium text-gray-700 mb-1">Teléfono</label>
            <input
                id="telefono"
                type="number"
                oninput={handleInputTelefono}
                bind:value={telefono}
                placeholder="Ingrese telefono"
                class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            />
        </div>
    </div>

    <!-- Segunda Fila -->
    <div class="grid grid-cols-4 gap-6 mb-8">
        <div class="flex flex-col">
            <label for="usuario" class="text-lg font-medium text-gray-700 mb-1">Usuario</label>
            <input
                id="usuario"
                type="text"
                bind:value={usuario}
                placeholder="Ingrese usuario"
                class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            />
        </div>
        <div class="flex flex-col">
            <label for="correo" class="text-lg font-medium text-gray-700 mb-1">Correo</label>
            <input
                id="correo"
                type="email"
                bind:value={correo}
                placeholder="Ingrese correo"
                class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            />
        </div>
        <div class="flex flex-col">
            <label for="genero" class="text-lg font-medium text-gray-700 mb-1">Género</label>
            <div class="flex flex-col">
                <select
                    id="genero"
                    bind:value={genero}
                    class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
                >
                    <option value="">Seleccione Género</option>
                    <option value="masculino">Masculino</option>
                    <option value="femenino">Femenino</option>
                </select>
            </div>            
        </div>
        <div class="flex flex-col">
            <label for="estadoCivil" class="text-lg font-medium text-gray-700 mb-1">Estado Civil</label>
            <select
                    id="estadoCivil"
                    bind:value={estadoCivil}
                    class="p-2 border border-gray-300 rounded-md focus:ring focus:ring-blue-300"
            >
                <option value="">Seleccione Estado Civil</option>
                <option value="soltero">Soltero</option>
                <option value="casado">Casado</option>
            </select>
        </div>
    </div>

    <!-- Tercera Fila -->
    <div class="grid grid-cols-2 gap-6">
        <!-- Foto -->
        <div class="flex flex-col text-center items-center justify-center">
            <label for="fotoform" class="block text-lg font-medium mb-2 text-gray-700">Subir Foto</label>
            <div id="fotoform" class="w-32 h-32 border-2 border-dashed border-gray-300 rounded flex items-center justify-center mb-4">
                {#if fotoPreview}
                    <img src={fotoPreview} alt="Foto" class="w-full h-full object-cover rounded" />
                {:else}
                    <span class="text-gray-400 text-sm">Vista previa</span>
                {/if}
            </div>
            <label
                class="cursor-pointer px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            >
                Subir foto
                <input
                    type="file"
                    accept="image/*"
                    class="hidden"
                    onchange={(e) => handleImageUpload(e, 'foto')}
                />
            </label>
        </div>

        <!-- Papelería -->
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
