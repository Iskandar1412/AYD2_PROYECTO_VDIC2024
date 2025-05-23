<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";
	import { generarContrasena } from "../../../utils/GeneracionPass";

    let usuarios = $state([]);

    let tipoBusqueda = $state("user");
    let filtroBusqueda = $state();
    let resultados = $state([]);
    let filtroBusquedaFull = $state(false);

    let papeleria = $state(null);

    function obtenerUsuarios() {
        fetch(`${PathBackend}/monitoreo/getallempleados`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                usuarios = data.empleados;
                resultados = data.empleados
                console.log(data);
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    onMount(() => { obtenerUsuarios() })

    function buscarUsuario() {
        if (filtroBusqueda) {
            resultados = usuarios.filter((usuario) => {
                const valorBusqueda = filtroBusqueda;
                if (tipoBusqueda === "user") {
                    return usuario.user.toLowerCase().includes(valorBusqueda.toLowerCase());
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

    function solicitudModificarPass(usuario) {
        const mailOptions = {
            from: 'no-reply@proyect1activate.com',
            to: 'XXXXX@gmail.com',
            subject: 'Cambio de Contraseña usuario',
            html: `<p>El usuario <strong>${usuario.usuario}</strong> quiere cambiar su contraseña<br/></p>`,
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
                alert('Solicitud enviada')
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
                obtenerUsuarios()
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

    function modificarPass(usuario) {
        let nuevaContra = generarContrasena()
        fetch(`${PathBackend}/administracion/cambio-pass1`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cui: usuario.dpi, contrasenia: nuevaContra })
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                cambioPass2(usuario, nuevaContra)
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
    }

    function eliminarUsuario(usuario) {
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
                alert('Usuario Eliminado')
                obtenerUsuarios()
            } else { throw new Error('Error en la obtención') }
        })
        .catch(er => { alert(er) })
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

    function handleSendEliminacion(usuario, papel) {
        // console.log(usuario)
        fetch(`${PathBackend}/administracion/sol-eliminacion`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ link_justificacion: papel, cui: usuario.dpi })
        })
        .then(res => {
            if(!res.ok) throw new Error('Internal Server Error')
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.message.status === 'success') {
                alert('Solicitud enviada exitosamente')
            }
        })
        .catch(er => { alert(er) })
    }

    async function handlePDFUpload(event, usuario) {
        const file = event.target.files[0];
        if (file && file.type === "application/pdf") {
            const reader = new FileReader();
            reader.onload = () => {
                papeleria = reader.result.toString().split(",")[1];
                // console.log("Archivo PDF en Base64:", papeleria);
                handleSendEliminacion(usuario, papeleria)
            };
            reader.readAsDataURL(file);
        } else {
            alert("Solo se permiten archivos PDF.");
            papeleria = null;
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
    <table class="table-auto w-full border-collapse border border-gray-300">
        <thead class="bg-gray-200">
            <tr>
                <th class="border px-4 py-2 bg-white text-center">User</th>
                <th class="border px-4 py-2 bg-white text-center">Nombres</th>
                <th class="border px-4 py-2 bg-white text-center">Apellidos</th>
                <th class="border px-4 py-2 bg-white text-center">Edad</th>
                <th class="border px-4 py-2 bg-white text-center">DPI</th>
                <th class="border px-4 py-2 bg-white text-center">Correo</th>
                <th class="border px-4 py-2 bg-white text-center">Modificar Password</th>
                <th class="border px-4 py-2 bg-white text-center">Eliminación Cuenta</th>
            </tr>
        </thead>
        <tbody>
            {#each resultados as usuario, index}
                <tr>
                    <td class="border px-4 py-2 text-center">{usuario.usuario}</td>
                    <td class="border px-4 py-2 text-center">{usuario.nombres}</td>
                    <td class="border px-4 py-2 text-center">{usuario.apellidos}</td>
                    <td class="border px-4 py-2 text-center">{usuario.edad}</td>
                    <td class="border px-4 py-2 text-center">{usuario.dpi}</td>
                    <td class="border px-4 py-2">{usuario.correo}</td>
                    <td class="border px-4 py-2 text-center">
                        <div class="flex justify-center gap-2">
                            <button
                                onclick={() => solicitudModificarPass(usuario)}
                                class="px-4 py-1 bg-gray-500 text-white rounded hover:bg-gray-600 button-ok-rol"
                                disabled={!usuario.rol}
                            >
                                Peticion
                            </button>
                            <button
                                onclick={() => modificarPass(usuario)}
                                class="px-4 py-1 bg-teal-500 text-white rounded hover:bg-teal-600 button-ok-rol"
                                disabled={!usuario.hab_pass || usuario.hab_pass === 0}
                            >
                                Modificar
                            </button>
                        </div>
                    </td>
                    <td class="border px-4 py-2 text-center">
                        <div class="flex justify-center gap-2">
                            <!-- Input para subir un PDF -->
                            <label
                                class="cursor-pointer px-4 py-1 bg-gray-500 text-white text-center rounded hover:bg-gray-600"
                            >
                                Peticion PDF
                                <input
                                    type="file"
                                    accept="application/pdf"
                                    class="hidden"
                                    onchange={(e) => handlePDFUpload(e, usuario)}
                                />
                            </label>
                        
                            <!-- Botón para eliminar -->
                            <button
                                onclick={() => eliminarUsuario(usuario)}
                                class="px-4 py-1 bg-amber-500 text-white rounded hover:bg-amber-600 button-ok-rol"
                                disabled={!usuario.hab_elim || usuario.hab_elim === 0}
                            >
                                Eliminar
                            </button>
                        </div>
                    </td>
                </tr>
            {/each}
        </tbody>
    </table>    
</div>

<style lang="scss">
    /* table th, table td {
        text-align: left;
    } */

    .button-ok-rol {
        &:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    }
</style>
