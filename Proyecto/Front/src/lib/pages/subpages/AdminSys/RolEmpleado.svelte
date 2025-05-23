<script>
	import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";

    let usuarios = $state([]);
    let resultados = $state([]);
    let tipoBusqueda = $state("user");
    let filtroBusqueda = $state(); 
    let filtroBusquedaFull = $state(false);
    // let resultados = $state([])
    // $effect(() => {resultados = [...usuarios]})

    function monitoreoUsuarios() {
        fetch(`${PathBackend}/monitoreo/empleados`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error('Error en la solicitud')
            return res.json()
        })
        .then(data => {
            if(data) {
                console.log(data)
                usuarios = data.empleados
                resultados = data.empleados
            }
        })
        .catch(er => {
            alert(er)
        })
    }

    onMount(( ) => {
        monitoreoUsuarios()
    })

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

    function actualizarRol(usuario) {
        fetch(`${PathBackend}/administracion/asignarRol`, {
            method: 'PUT',
            headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ empleado_id: usuario.dpi, rol: usuario.rol })
        })
        .then(res => {
            if(!res.ok) throw new Error("Error en la solicitud")
            return res.json()
        })
        .then(data => {
            console.log(data)
            alert(`Rol Actualizado para el usuario: ${usuario.usuario}`)
            monitoreoUsuarios()
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

</script>

<svelte:head>
	<title>Empleados (Roles)</title>
</svelte:head>
<h1 class="text-2xl font-bold mb-6">Roles Empleados</h1>
<div class="w-4/5 mx-auto">
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
                <th class="border px-4 py-2 bg-white text-center">Rol</th>
                <th class="border px-4 py-2 bg-white text-center">Acción</th>
            </tr>
        </thead>
        <tbody>
            {#each resultados as usuario, index}
                {#if usuario.rol !== 'administrador'}
                <tr>
                    <td class="border px-4 py-2">{usuario.usuario}</td>
                    <td class="border px-4 py-2">{usuario.nombres}</td>
                    <td class="border px-4 py-2">{usuario.apellidos}</td>
                    <td class="border px-4 py-2">{usuario.edad}</td>
                    <td class="border px-4 py-2">{usuario.dpi}</td>
                    <td class="border px-4 py-2">{usuario.correo}</td>
                    <td class="border px-4 py-2">
                        <select
                            bind:value={usuario.rol}
                            class="p-2 border border-gray-300 rounded-md"
                        >
                            <option value="pendiente">N/A</option>
                            <option value="cajero">Cajero</option>
                            <option value="atencion">Atención al Cliente</option>
                        </select>
                    </td>
                    <td class="border px-4 py-2">
                        <button
                            onclick={() => actualizarRol(usuario)}
                            class="px-4 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 button-ok-rol"
                            disabled={!usuario.rol || usuario.rol === 'pendiente'}
                        >
                            Update
                        </button>
                    </td>
                </tr>
                {/if}
            {/each}
        </tbody>
    </table>
</div>

<style>
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
