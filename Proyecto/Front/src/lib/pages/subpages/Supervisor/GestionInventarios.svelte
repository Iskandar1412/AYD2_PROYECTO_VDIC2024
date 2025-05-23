<script>
    import { onMount } from "svelte";
	import Inventarios from "./charts/Inventarios.svelte";
	import { PathBackend } from "../../../stores/host";
	// import { dataToSendGraphIngentario } from "./charts/storeInventario";

    let dineroQ = $state(0);
    let dineroD = $state(0);
    let entradasSalidas = $state([]);
    let resultados = $state([]);    
    let dataToSendGraph = $state({});

    function handleMonitoreoInventario() {
        fetch(`${PathBackend}/monitoreo/inventario/${1}`, { method: "GET" })
            .then((res) => {
                if (!res.ok) throw new Error("Error al obtener estadísticas");
                return res.json();
            })
            .then((data) => {
                if (data.status === "success") {
                    dineroQ = data.dinero_quetzales;
                    dineroD = data.dinero_dolares;
                    entradasSalidas = data.transacciones;
                    resultados = data.transacciones;

                    const lab = [];
                    const ent = [];
                    const ret = [];

                    data.transacciones.forEach(({ tipo, fecha, monto }) => {
                        fecha = fecha.split(" ")[0];
                        if (tipo === "deposito") {
                            lab.push(fecha);
                            ent.push(monto);
                            ret.push(0);
                        } else if (tipo === "retiro") {
                            lab.push(fecha);
                            ent.push(0);
                            ret.push(monto);
                        }
                    });

                    // Actualizar el estado reactivo de la gráfica
                    dataToSendGraph = {
                        labels: lab,
                        datasets: [
                            {
                                label: "Entradas",
                                data: ent,
                                borderColor: "rgba(75, 192, 192, 1)",
                                backgroundColor: "rgba(75, 192, 192, 0.2)",
                                fill: true,
                            },
                            {
                                label: "Salidas",
                                data: ret,
                                borderColor: "rgba(255, 99, 132, 1)",
                                backgroundColor: "rgba(255, 99, 132, 0.2)",
                                fill: true,
                            },
                        ],
                    };
                }
            })
            .catch((error) => alert(error.message));
    }

    onMount(() => {handleMonitoreoInventario()})

    let filtroAnio = $state("");
    let filtroMes = $state("");
    let filtroTipo = $state("");

    

    function filtrarEntradasSalidas() {
        resultados = entradasSalidas.filter((item) => {
            const [anio, mes] = item.fecha.split("-");
            const cumpleAnio = !filtroAnio || anio === filtroAnio;
            const cumpleMes = !filtroMes || mes === filtroMes;
            const cumpleTipo = !filtroTipo || 
            (filtroTipo === 'Salida' ? item.tipo === 'retiro' : item.tipo !== 'retiro');

            return cumpleAnio && cumpleMes && cumpleTipo;
        });
    }

    function descargarReporte() {
        const contenido = `Dinero Disponible en Q.: ${dineroQ}\nDinero Disponible en USD: ${dineroD}\nEntradas y Salidas:\n${resultados
            .map((e) => `${e.tipo} - ${e.fecha} - ${e.monto}`)
            .join('\n')}`;

        const blob = new Blob([contenido], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'reporte_inventarios.txt';
        a.click();
        URL.revokeObjectURL(url);
    }

    onMount(() => {
        filtrarEntradasSalidas();
    });
</script>


<svelte:head>
	<title>Inventarios</title>
</svelte:head>
<div class="flex justify-between items-center mb-8">
    <h1 class="text-2xl font-bold text-gray-800">Inventarios</h1>
    <button
        onclick={descargarReporte}
        class="px-4 py-2 bg-blue-500 text-white font-semibold rounded hover:bg-blue-600"
    >
        Descargar Reporte
    </button>
</div>
<div class="grid grid-cols-2 gap-6 mb-8">
    <div class="flex flex-col items-center bg-white border border-gray-300 shadow-md rounded-lg p-6 w-1/2 m-auto">
        <h2 class="text-xl font-bold text-gray-800 mb-4">Dinero Disponible en Q.</h2>
        <div class="text-3xl font-semibold text-green-500">
            {dineroQ.toLocaleString("en-US", { minimumFractionDigits: 2 })}
        </div>
    </div>

    <div class="flex flex-col items-center bg-white border border-gray-300 shadow-md rounded-lg p-6 w-1/2 m-auto">
        <h2 class="text-xl font-bold text-gray-800 mb-4">Dinero Disponible en $.</h2>
        <div class="text-3xl font-semibold text-blue-500">
            {dineroD.toLocaleString("en-US", { minimumFractionDigits: 2 })}
        </div>
    </div>
</div>
<div class="grid grid-cols-2 gap-6 mt-8">
    <!-- Tabla de Entradas y Salidas -->
    <div class="bg-white border border-gray-300 shadow-md rounded-lg p-6 barte">
        <h3 class="text-lg font-bold mb-4 text-gray-800 text-center">Entradas y Salidas</h3>
        <div class="flex gap-4 mb-4 justify-center">
            <!-- Filtro por Tipo (Entrada/Salida) -->
            <select
                bind:value={filtroTipo}
                onchange={filtrarEntradasSalidas}
                class="p-2 border border-gray-300 rounded-md"
            >
                <option value="">Entradas y Salidas</option>
                <option value="Entrada">Entradas</option>
                <option value="Salida">Salidas</option>
            </select>

            <!-- Filtro por Año -->
            <select
                bind:value={filtroAnio}
                onchange={filtrarEntradasSalidas}
                class="p-2 border border-gray-300 rounded-md"
            >
                <option value="">Todos los años</option>
                <option value="2023">2023</option>
                <option value="2024">2024</option>
            </select>
    
            <!-- Filtro por Mes -->
            <select
                bind:value={filtroMes}
                onchange={filtrarEntradasSalidas}
                class="p-2 border border-gray-300 rounded-md"
            >
                <option value="">Todos los meses</option>
                <option value="01">Enero</option>
                <option value="02">Febrero</option>
                <option value="03">Marzo</option>
                <option value="04">Abril</option>
                <option value="05">Mayo</option>
                <option value="06">Junio</option>
                <option value="07">Julio</option>
                <option value="08">Agosto</option>
                <option value="09">Septiembre</option>
                <option value="10">Octubre</option>
                <option value="11">Noviembre</option>
                <option value="12">Diciembre</option>
            </select>
        </div>
        <div class="overflow-y-auto max-h-80 border rounded-md">
            {#if Array.isArray(resultados)}
                <table class="table-auto w-full border-collapse border border-gray-300">
                    <thead class="bg-gray-200">
                        <tr>
                            <th class="border px-4 py-2 text-center">E/S</th>
                            <th class="border px-4 py-2 text-center">Monto</th>
                            <th class="border px-4 py-2 text-center">Fecha</th>
                        </tr>
                    </thead>
                    <tbody>
                        {#each resultados as item}
                            <tr>
                                <td class="border px-4 py-2 text-center">{item.tipo}</td>
                                <td class="border px-4 py-2 text-center">{item.monto}</td>
                                <td class="border px-4 py-2 text-center">{item.fecha}</td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            {:else}
                <p class="text-center">No hay transacciones</p>
            {/if}
        </div>
    </div>

    <!-- Gráfica de Ganancias y Pérdidas -->
    <div class="bg-white border border-gray-300 shadow-md rounded-lg p-6 barte">
        <h3 class="text-lg font-bold mb-4 text-gray-800 text-center">Ganancias y pérdidas a lo largo del tiempo</h3>
        <div class="border rounded-md flex items-center justify-center bg-gray-100 ibarte">
            <Inventarios data={dataToSendGraph} />
        </div>
    </div>
</div>

<style>
    .overflow-y-auto::-webkit-scrollbar {
        width: 8px;
    }
    .overflow-y-auto::-webkit-scrollbar-track {
        background: #f1f1f1;
    }
    .overflow-y-auto::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 4px;
    }
    .overflow-y-auto::-webkit-scrollbar-thumb:hover {
        background: #555;
    }
    .overflow-y-auto {
        scrollbar-width: thin;
        scrollbar-color: #888 #f1f1f1;
    }

    .barte {
        height: 30em;
    }

    .ibarte {
        height: 23em;
    }
</style>