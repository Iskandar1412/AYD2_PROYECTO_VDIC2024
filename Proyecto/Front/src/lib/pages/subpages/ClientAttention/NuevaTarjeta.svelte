<script>
	import NTarjeta from "./Gestiones/NTarjeta.svelte";
	import NTarjetaSearch from "./Gestiones/NTarjetaSearch.svelte";

	

    let activeTab = $state("prestamos");

    const tabs = $state([
        { id: "prestamos", label: "Nueva Tarjeta" },
        { id: "eliminarEmpleado", label: "Buscar Solicitud Tarjeta" },
    ]);
</script>

<svelte:head>
	<title>Nueva Tarjeta</title>
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
            <NTarjeta />
        {/if}
        {#if activeTab === "eliminarEmpleado"}
            <div class="flex items-center mb-6">
                <h2 class="text-xl font-bold px-6 py-2">Estado Solicitud Tarjeta</h2>
            </div>
            <NTarjetaSearch />
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
