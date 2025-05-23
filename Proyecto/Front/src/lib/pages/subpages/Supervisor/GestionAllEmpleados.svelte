<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";
	import { generarContrasena } from "../../../utils/GeneracionPass";

    let usuarios = $state([]);

    let tipoBusqueda = $state("user");
    let filtroBusqueda = $state();
    let filtroBusquedaFull = $state(false);
    let selectedUsuario = $state(null);
    let inputTelefonoFull = $state(false);
    let fotoPreview = $state(null);
    let fotoBase64 = $state(null);
    let resultados = $state([])
    
    function handleObtainUsuarios() {
        fetch(`${PathBackend}/monitoreo/empleados`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            if(data.status === 'success') {
                usuarios = data.empleados;
                resultados = data.empleados
                console.log(data);
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => {
        handleObtainUsuarios()
    })

    function handleSendEmail(usuario, pass) {
        const mailOptions = {
            from: 'no-reply@proyect1activate.com',
            to: usuario.correo,
            subject: 'Cambio de Contraseña',
            html: `<p>Su cuenta <strong>${usuario.usuario}</strong><br/>su contraseña nueva: ${pass}</p>`,
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

    function cambioPass2(usuario, pass) {
        fetch(`${PathBackend}/administracion/cambio-pass2`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cui: usuario.dpi })
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                handleSendEmail(usuario, pass)
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    function handleModificarPassword(usuario) {
        let url = usuario.rol !== 'administrador' ?
            `${PathBackend}/monitoreo/habilitar-cambio` : 
            `${PathBackend}/administracion/cambio-pass1`
        
        let passnew = generarContrasena()
        let jsontoSendtoPass = usuario.rol === 'administrador' ?
            { cui: usuario.dpi, contrasenia: passnew } :
            { cui: usuario.dpi }

        fetch(url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(jsontoSendtoPass)
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                alert(usuario.rol === 'administrador' ? `Cambiando contraseña a administrador: ${usuario.usuario}` : `Desbloqueado: ${usuario.usuario}`)
                if (usuario.rol === 'administrador') {
                    cambioPass2(usuario, passnew)
                }
                handleObtainUsuarios()
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    function handleDeleteAdUs(usuario) {
        fetch(`${PathBackend}/administracion/elim-empleado`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cui: usuario.dpi })
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                alert('Admin Eliminado')
                handleObtainUsuarios()
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    function handleEliminarUsuario(usuario) {
        // const index = usuarios.findIndex(u => u.usuario === usuario.usuario);
        // if (index !== -1) {
        //     usuarios.splice(index, 1);
        //     resultados = [...usuarios];
        //     console.log("Usuario eliminado:", usuario);
        // } else {
        //     console.log("Usuario no encontrado");
        // }
        fetch(`${PathBackend}/administracion/sol-eliminacion`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cui: usuario.dpi, link_justificacion: ' ' })
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log("cas", data)
            if(data.message.status === 'success') {
                handleDeleteAdUs(usuario)
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    function handleModificarUsuario(usuario) {
        selectedUsuario = { ...usuario };
    }

    function aceptarCambios() {
        let JsonToSend = {
            identificador: selectedUsuario.dpi,
            telefono: Number(selectedUsuario.telefono),
            correo: selectedUsuario.correo,
            genero: selectedUsuario.genero,
            link_foto: fotoBase64,
            estado_civil: selectedUsuario.estadoCivil
        }

        fetch(`${PathBackend}/administracion/update-empleado`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(JsonToSend)
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            if(data.message.status === 'success') {
                // console.log(data)
                alert('Datos cambiados exitosamente')
                selectedUsuario = null;
                fotoPreview = null;
                fotoBase64 = null;
                handleObtainUsuarios()
            }
        })
        .catch(er => { alert(er) })
    }

    function buscarUsuario() {
        if (filtroBusqueda) {
            resultados = usuarios.filter((usuario) => {
                const valorBusqueda = filtroBusqueda;
                if (tipoBusqueda === "user") {
                    return usuario.usuario.toLowerCase().includes(valorBusqueda.toLowerCase());
                }
                if (tipoBusqueda === "correo") {
                    return usuario.correo.toLowerCase().includes(valorBusqueda.toLowerCase());
                }
                if (tipoBusqueda === "dpi") {
                    console.log(filtroBusqueda);
                    
                    return usuario.dpi.toString().includes(valorBusqueda);
                }
                return false;
            });
        } else {
            resultados = [...usuarios];
        }
    }

    function handleBusquedaChange() {
        filtroBusqueda = null;
        resultados = [...usuarios];
    }

    function handleInput(event) {
        const value = event.target.value;

        if (tipoBusqueda === 'dpi') {
            filtroBusqueda = value.slice(0, 13);

            if (filtroBusqueda.length < 13) {
                filtroBusquedaFull = false;
            } else if (filtroBusqueda.length === 13) {
                filtroBusquedaFull = true;
            }
        } else {
            filtroBusqueda = value;
            filtroBusquedaFull = true;
        }
    }

    function handleInputTelefono(event) {
        const value = event.target.value.slice(0, 8);
        selectedUsuario.telefono = value; 
        inputTelefonoFull = value.length === 8;
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
</script>

<svelte:head>
	<title>Gestión Empleados</title>
</svelte:head>
<h1 class="text-2xl font-bold mb-6">Gestión Empleados</h1>
<div class="mx-auto">
    <!-- Barra de búsqueda -->
    <div class="flex items-center gap-4 mb-4">
        <select
            bind:value={tipoBusqueda}
            class="p-2 border border-gray-300 rounded-md"
            onchange={handleBusquedaChange}
        >
            <option value="user">Buscar por Usuario</option>
            <option value="correo">Buscar por Correo</option>
            <option value="dpi">Buscar por DPI</option>
        </select>
        <input
            type={tipoBusqueda === 'dpi' ? "number" : "text"}
            placeholder={`Buscar por ${
                tipoBusqueda === 'dpi' ? "DPI" : tipoBusqueda === 'user' ?  "Usuario" : tipoBusqueda === 'correo' ? 'Correo' : tipoBusqueda
            }`}
            oninput={(e) => {
                buscarUsuario();
                if (tipoBusqueda === 'dpi') {
                    handleInput(e);
                }
            }}
            bind:value={filtroBusqueda}
            class="p-2 border border-gray-300 rounded-md flex-grow"
        />
    </div>

    <!-- Tabla -->
    <div class="w-full overflow-y-auto mb-6" style="max-height: 400px;">
        <table class="table-auto w-full border-collapse border border-gray-300">
            <thead class="bg-gray-200">
                <tr>
                    <th class="border px-4 py-2 bg-white text-center">User</th>
                    <th class="border px-4 py-2 bg-white text-center">Nombres</th>
                    <th class="border px-4 py-2 bg-white text-center">Edad</th>
                    <th class="border px-4 py-2 bg-white text-center">DPI</th>
                    <th class="border px-4 py-2 bg-white text-center">Teléfono</th>
                    <th class="border px-4 py-2 bg-white text-center">Correo</th>
                    <th class="border px-4 py-2 bg-white text-center">Rol</th>
                    <th class="border px-4 py-2 bg-white text-center">Modificar Info</th>
                    <!-- <th class="border px-4 py-2 bg-white text-center">Solicitud Pass</th> -->
                    <th class="border px-4 py-2 bg-white text-center">Contraseña</th>
                    <th class="border px-4 py-2 bg-white text-center">Eliminación</th>
                </tr>
            </thead>
            <tbody>
                {#each resultados as usuario, index}
                    <tr>
                        <td class="border px-4 py-2">{usuario.usuario}</td>
                        <td class="border px-4 py-2">{usuario.nombres} {usuario.apellidos}</td>
                        <td class="border px-4 py-2">{usuario.edad}</td>
                        <td class="border px-4 py-2">{usuario.dpi}</td>
                        <td class="border px-4 py-2">{usuario.telefono}</td>
                        <td class="border px-4 py-2">{usuario.correo}</td>
                        <td class="border px-4 py-2 text-center">
                            {
                                usuario.rol === 'administrador' ? "System Admin" :
                                usuario.rol === 'supervisor' ? "Supervisor" :
                                usuario.rol === 'atencion' ? "Atención Cliente" :
                                usuario.rol === 'cajero' ? "Cajero" : usuario.rol
                            }
                        </td>
                        <td class="border px-4 py-2 text-center">
                            <div class="flex justify-center gap-2">
                                
                                <button
                                    onclick={() => handleModificarUsuario(usuario)}
                                    class={
                                        usuario.rol === 'administrador' ? 
                                        "px-4 py-1 bg-slate-500 text-white rounded hover:bg-slate-600 button-ok-rol" :
                                        "px-4 py-1 bg-gray-500 text-white rounded hover:bg-gray-600 button-ok-rol"
                                    }
                                    disabled={!usuario.rol}
                                >
                                    Actualizar
                                </button>
                            </div>
                        </td>
                        <!-- <td class="border px-4 py-2 text-center">{`si`}</td> -->
                        <td class="border px-4 py-2 text-center">
                            <div class="flex justify-center gap-2">
                                
                                <button
                                    onclick={() => handleModificarPassword(usuario)}
                                    class={
                                        usuario.rol === 'administrador' ? 
                                        "px-4 py-1 bg-teal-500 text-white rounded hover:bg-teal-600 button-ok-rol" :
                                        "px-4 py-1 bg-emerald-500 text-white rounded hover:bg-emerald-600 button-ok-rol"
                                    }
                                    disabled={!usuario.rol}
                                >
                                    {
                                        usuario.rol === 'administrador' 
                                        ? "Modificar" : "Unlock"
                                    }
                                </button>
                            </div>
                        </td>
                        <td class="border px-4 py-2 text-center">
                            {#if usuario.rol === "administrador"}
                            <div class="flex justify-center gap-2">
                                <!-- Botón para eliminar -->
                                <button
                                    onclick={() => handleEliminarUsuario(usuario)}
                                    class="px-4 py-1 bg-rose-500 text-white rounded hover:bg-rose-600 button-ok-rol"
                                    disabled={!usuario.rol}
                                >
                                    Eliminar
                                </button>
                            </div>
                            {/if}
                        </td>
                    </tr>
                {/each}
            </tbody>
        </table> 
    </div>

    <!-- Modificación de Usuarios -->
    {#if selectedUsuario}
        <div class="p-4 border border-gray-300 rounded-md bg-gray-100">
            <h2 class="text-xl font-bold mb-4">Modificar Usuario: {selectedUsuario.nombres} {selectedUsuario.apellidos}</h2>

            <label for="inputTelefono" class="block mb-2">Teléfono:</label>
            <input
                id="inputTelefono"
                type="number"
                bind:value={selectedUsuario.telefono}
                oninput={handleInputTelefono}
                maxlength="8"
                class="p-2 border border-gray-300 rounded-md w-full mb-4"
                placeholder="Número de teléfono"
            />

            <label for="inputCorreo" class="block mb-2">Correo Electrónico:</label>
            <input
                id="inputCorreo"
                type="email"
                bind:value={selectedUsuario.correo}
                class="p-2 border border-gray-300 rounded-md w-full mb-4"
                placeholder="Correo Electrónico"
            />

            <label for="inputGenero" class="block mb-2">Género:</label>
            <select
                id="inputGenero"
                bind:value={selectedUsuario.genero}
                class="p-2 border border-gray-300 rounded-md w-full mb-4"
            >
                <option value="Masculino">Masculino</option>
                <option value="Femenino">Femenino</option>
            </select>

            <label for="inputEC" class="block mb-2">Estado Civil:</label>
            <select
                id="inputEC"
                bind:value={selectedUsuario.estadoCivil}
                class="p-2 border border-gray-300 rounded-md w-full mb-4"
            >
                <option value="">Seleccione Estado Civil</option>
                <option value="soltero">Soltero</option>
                <option value="casado">Casado</option>
            </select>
            <div class="flex flex-col text-center items-center justify-center">
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
                    Subir Foto
                    <input
                        id="inputFot"
                        type="file"
                        accept="image/*"
                        class="hidden"
                        onchange={(e) => handleImageUpload(e)}
                        
                    />
                </label>
            </div>

            <button
                onclick={aceptarCambios}
                class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 button-ok-rol"
                disabled={
                    !selectedUsuario.estadoCivil ||
                    !selectedUsuario .genero || 
                    !selectedUsuario.correo ||
                    !inputTelefonoFull ||
                    !fotoBase64
                }
            >
                Aceptar Cambios
            </button>
        </div>
    {/if}  
</div>

<style lang="scss">
    .button-ok-rol {
        &:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    }

    ::-webkit-scrollbar {
        width: 6px;
        height: 6px;
    }

    ::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 10px;
    }

    ::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 10px;
    }

    ::-webkit-scrollbar-thumb:hover {
        background: #555;
    }

    * {
        scrollbar-width: thin;
        scrollbar-color: #888 #f1f1f1;
    }
</style>
