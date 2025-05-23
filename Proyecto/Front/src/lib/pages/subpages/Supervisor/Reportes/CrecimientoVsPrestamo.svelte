<!-- TasaCrecimientoCarteraClientesVsVolumenPrestamo -->
<script>
    import { onMount, onDestroy } from 'svelte';
    import { Chart, registerables } from 'chart.js';

    Chart.register(...registerables);

    export let data;

    let canvas;
    let chartInstance;

    const options = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            tooltip: {
                enabled: true,
            },
        },
        scales: {
            x: { title: { display: true, text: 'Años' } },
            y: { title: { display: true, text: 'Crecimiento (%)' } },
        },
    };

    const createChart = () => {
        if (canvas) {
            const ctx = canvas.getContext('2d');
            if (chartInstance) {
                chartInstance.destroy();
            }
            chartInstance = new Chart(ctx, {
                type: 'line',
                data,
                options,
            });
        }
    };

    onDestroy(() => {
        if (chartInstance) {
            chartInstance.destroy();
        }
    });

    onMount(() => {
        createChart();
    });

    $: if (data && chartInstance) {
        createChart();
    }
</script>

<div style="height: 400px; width: 100%;">
    <canvas bind:this={canvas}></canvas>
</div>
