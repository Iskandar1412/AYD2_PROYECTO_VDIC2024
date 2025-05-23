<script>
	import NPrestamo from "./Prestamos/NPrestamo.svelte";
	import NPrestamoSearch from "./Prestamos/NPrestamoSearch.svelte";
	let activeTab = $state("solicitudPrestamo");

    const tabs = $state([
        { id: "solicitudPrestamo", label: "Nueva Solicitud de Prestamo" },
        { id: "PrestamoSearch", label: "Buscar Solicitud" },
    ]);
</script>

<svelte:head>
	<title>Solicitud Prestamos</title>
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
        {#if activeTab === "solicitudPrestamo"}
            <NPrestamo />
        {/if}
        {#if activeTab === "PrestamoSearch"}
            <div class="flex items-center mb-6">
                <h2 class="text-xl font-bold px-6 py-2">Estado Solicitud Prestamo</h2>
            </div>
            <NPrestamoSearch />
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
