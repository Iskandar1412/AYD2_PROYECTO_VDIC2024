<script>
    import { onMount } from "svelte";
	import { PathBackend } from "../../../stores/host";
	import { calcularEdad } from "../../../utils/GeneracionPass";

    // Valores dinámicos para retiros, depósitos y bloqueos
    let retiros = $state(0);
    let depositos = $state(0);
    let bloqueos = $state(0);
    
    // Datos de alertas
    let alertas = $state([]);

    // Datos para asignación de roles
    let empleados = $state([]);

    // Datos de usuarios eliminados
    let usuariosEliminados = $state([]);

    function handleObtainInTime() {
        fetch(`${PathBackend}/monitoreo/monitoreo`, {
            method: 'GET'
        })
        .then(res => {
            if(!res.ok) throw new Error("Internal Server Error")
            return res.json()
        })
        .then(data => {
            console.log(data)
            if(data.status === 'success') {
                empleados = data.actividadesAdmin
                usuariosEliminados = data.despidos
                alertas = data.alertas
                retiros = data.retiros
                depositos = data.solicitud_prestamos
                bloqueos = data.bloqueos
            } else { throw new Error('Error en la obtención de la información') }
        })
        .catch(er => {
            alert(er)
        })
    }

    onMount(() => {
        handleObtainInTime()
    })

    $effect(() => {
        const interval = setInterval(() => {
            handleObtainInTime();
        }, 3000);

        // Limpieza del intervalo al desmontar el efecto
        return () => clearInterval(interval);
    });


    // Filtros para la tabla de roles
    let filtroUsuario = $state("");
    let filtroFecha = $state("");
    let filtroRol = $state("");

    function filtrarEmpleados() {
        return empleados.filter((empleado) => {
            const coincideUsuario = !filtroUsuario || empleado.user.includes(filtroUsuario);
            const coincideFecha = !filtroFecha || empleado.fecha.startsWith(filtroFecha);
            const coincideRol = !filtroRol || empleado.rol === filtroRol;

            return coincideUsuario && coincideFecha && coincideRol;
        });
    }


    function descargarReporte() {
        const contenido = `Dinero Disponible en`;

        const blob = new Blob([contenido], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'reporte_inventarios.txt';
        a.click();
        URL.revokeObjectURL(url);
    }
</script>

<svelte:head>
	<title>Actividad Tiempo Real</title>
</svelte:head>
<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Actividad Tiempo Real</h1>
    <button
        onclick={descargarReporte}
        class="px-4 py-2 bg-blue-500 text-white font-semibold rounded hover:bg-blue-600"
    >
        Descargar Reporte
    </button>
</div>
<div class="grid grid-cols-2 gap-6 p-6">
    <!-- Sección Retiros, Depósitos, Bloqueos -->
    <div class="grid grid-cols-3 gap-4">
        <!-- Retiros -->
        <div class="flex flex-col items-center justify-center border rounded-lg p-4 bg-white shadow-md h-32">
            <h3 class="text-lg font-bold mb-4">Retiros</h3>
            <p class="text-2xl font-semibold text-blue-500">{retiros}</p>
        </div>
    
        <!-- Depósitos -->
        <div class="flex flex-col items-center justify-center border rounded-lg p-4 bg-white shadow-md h-32">
            <h3 class="text-lg font-bold mb-4">Solicitud Prestamos</h3>
            <p class="text-2xl font-semibold text-green-500">{depositos}</p>
        </div>
    
        <!-- Bloqueo Tarjetas -->
        <div class="flex flex-col items-center justify-center border rounded-lg p-4 bg-white shadow-md h-32">
            <h3 class="text-lg font-bold mb-4">Bloqueo Tarjetas</h3>
            <p class="text-2xl font-semibold text-red-500">{bloqueos}</p>
        </div>
    </div>
    
    <!-- Tabla de Alertas -->
    <div class="border rounded-lg p-4 bg-white shadow-md max-h-54">
        <h3 class="text-lg font-bold mb-4 text-center">Alertas</h3>
        <div class="overflow-y-auto max-h-48">
            {#if Array.isArray(alertas)}
            <table class="table-auto w-full border-collapse border border-gray-300">
                <thead class="bg-gray-200">
                    <tr>
                        <th class="border px-4 py-2 text-center">Tipo Alerta</th>
                        <th class="border px-4 py-2 text-center">Fecha</th>
                        <th class="border px-4 py-2 text-center">Descripción</th>
                    </tr>
                </thead>
                <tbody>
                    {#each alertas as alerta}
                        <tr>
                            <td class="border px-4 py-2 text-center">{alerta.tipo}</td>
                            <td class="border px-4 py-2 text-center">{alerta.fecha.split('T')[0]}</td>
                            <td class="border px-4 py-2 text-center">{alerta.descripcion}</td>
                        </tr>
                    {/each}
                </tbody>
            </table>
            {/if}
        </div>
    </div>
</div>
<div class="grid grid-cols-3 gap-4">
    <!-- Tabla de Roles -->
    <div class="col-span-2 border rounded-lg p-4 bg-white shadow-md">
        <h3 class="text-lg font-bold mb-4 text-center">Registro y Asignación de Roles</h3>
        <div class="flex gap-4 mb-4">
            <input
                type="text"
                placeholder="Buscar Usuario"
                bind:value={filtroUsuario}
                class="p-2 border rounded flex-grow"
                oninput={filtrarEmpleados}
            />
            <select
                bind:value={filtroFecha}
                class="p-2 border rounded"
                onchange={filtrarEmpleados}
            >
                <option value="">Todos los años</option>
                <option value="2024">2024</option>
                <option value="2023">2023</option>
            </select>
            <select
                bind:value={filtroRol}
                class="p-2 border rounded"
                onchange={filtrarEmpleados}
            >
                <option value="">Todos los roles</option>
                <option value="cajero">Cajero</option>
                <option value="atencion">Atención al Cliente</option>
            </select>
        </div>
        <div class="overflow-y-auto max-h-64">
            {#if Array.isArray(empleados)}
            <table class="table-auto w-full border-collapse border border-gray-300">
                <thead class="bg-gray-200">
                    <tr>
                        <th class="border px-4 py-2 text-center">User</th>
                        <th class="border px-4 py-2 text-center">Nombres</th>
                        <th class="border px-4 py-2 text-center">Edad</th>
                        <th class="border px-4 py-2 text-center">Fecha</th>
                        <th class="border px-4 py-2 text-center">Rol</th>
                        <th class="border px-4 py-2 text-center">No. Cambios Pass</th>
                    </tr>
                </thead>
                <tbody>
                    {#each filtrarEmpleados() as empleado}
                        <tr>
                            <td class="border px-4 py-2 text-center">{empleado.usuario}</td>
                            <td class="border px-4 py-2 text-center">{empleado.nombres}</td>
                            <td class="border px-4 py-2 text-center">{calcularEdad(empleado.fecha_nac)}</td>
                            <td class="border px-4 py-2 text-center">{empleado.fecha.split('T')[0]}</td>
                            <td class="border px-4 py-2 text-center">{empleado.rol}</td>
                            <td class="border px-4 py-2 text-center">{empleado.cambios_contra}</td>
                        </tr>
                    {/each}
                </tbody>
            </table>
            {/if}
        </div>
    </div>

    <!-- Tabla de Usuarios Eliminados -->
    <div class="border rounded-lg p-4 bg-white shadow-md">
        <h3 class="text-lg font-bold mb-4 text-center">Usuarios Eliminados</h3>
        <div class="overflow-y-auto max-h-64">
            {#if Array.isArray(usuariosEliminados)}
            <table class="table-auto w-full border-collapse border border-gray-300">
                <thead class="bg-gray-200">
                    <tr>
                        <th class="border px-4 py-2 text-center">User</th>
                        <th class="border px-4 py-2 text-center">Fecha</th>
                        <th class="border px-4 py-2 text-center">Nombres</th>
                    </tr>
                </thead>
                <tbody>
                    {#each usuariosEliminados as usuario}
                        <tr>
                            <td class="border px-4 py-2 text-center">{usuario.usuario}</td>
                            <td class="border px-4 py-2 text-center">{usuario.fecha.split('T')[0]}</td>
                            <td class="border px-4 py-2 text-center">{usuario.nombres}</td>
                        </tr>
                    {/each}
                </tbody>
            </table>
            {/if}
        </div>
    </div>
</div>

<style>
    .shadow-md {
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .max-h-64::-webkit-scrollbar {
        width: 6px;
    }

    .max-h-64::-webkit-scrollbar-thumb {
        background-color: #c0c0c0;
        border-radius: 4px;
    }
        
    .max-h-48::-webkit-scrollbar {
        width: 6px;
    }

    .max-h-48::-webkit-scrollbar-thumb {
        background-color: #c0c0c0;
        border-radius: 4px;
    }
</style>
