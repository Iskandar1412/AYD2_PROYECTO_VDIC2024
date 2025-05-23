<script>
	import CancelacionServicio from "./Gestiones/CancelacionServicio.svelte";
	import CancelacionTarjeta from "./Gestiones/CancelacionTarjeta.svelte";
    import EliminarEmpleado from "./Gestiones/EliminarEmpleado.svelte";
    import Prestamos from "./Gestiones/Prestamos.svelte";

    let activeTab = $state("prestamos");

    const tabs = $state([
        { id: "prestamos", label: "Peticiones Prestamos" },
        { id: "eliminarEmpleado", label: "Petición Eliminar Empleado" },
        { id: "tarjetas", label: "Petición Tarjetas" },
        { id: "cancelaciones", label: "Petición Cancelación Servicios" }
    ]);
</script>

<svelte:head>
	<title>Solicitudes</title>
</svelte:head>
<div class="tabs-container">
    <!-- Tabs Navigation -->
    <div class="tabs">
        {#each tabs as tab}
            <button
                class:active={activeTab === tab.id}
                class="tab"
                onclick={() => (activeTab = tab.id)}
            >
                {tab.label}
            </button>
        {/each}
    </div>

    <!-- Tab Content -->
    <div class="tab-content">
        {#if activeTab === "prestamos"}
            <h2 class="text-xl font-bold mb-4">Peticiones Prestamos</h2>
            <Prestamos />
        {/if}
        {#if activeTab === "eliminarEmpleado"}
            <h2 class="text-xl font-bold mb-4">Petición Eliminar Empleado</h2>
            <EliminarEmpleado />
        {/if}
        {#if activeTab === "tarjetas"}
            <h2 class="text-xl font-bold mb-4">Petición Tarjetas</h2>
            <CancelacionTarjeta />
        {/if}
        {#if activeTab === "cancelaciones"}
            <h2 class="text-xl font-bold mb-4">Peticiones Cancelaciones de Servicios</h2>
            <CancelacionServicio />
        {/if}
    </div>
</div>

<style>
    .tabs {
        display: flex;
        gap: 10px;
        margin-bottom: 16px;
    }

    .tab {
        padding: 8px 16px;
        border: 1px solid #ccc;
        background: #f9f9f9;
        border-radius: 4px;
        cursor: pointer;
    }

    .tab.active {
        background: #007bff;
        color: #fff;
        border-color: #007bff;
    }

    .tab-content {
        padding: 16px;
        border: 1px solid #ccc;
        border-radius: 4px;
        background: #fff;
    }
</style>
