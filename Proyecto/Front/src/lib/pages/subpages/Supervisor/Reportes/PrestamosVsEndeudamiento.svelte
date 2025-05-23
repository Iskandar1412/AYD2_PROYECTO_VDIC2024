<!-- Exposición de riesgos por préstamos vs endeudamiento de clientes -->
<script>
    import { onMount, onDestroy } from 'svelte';
    import { Chart, registerables } from 'chart.js';

    Chart.register(...registerables);

    let { data } = $props();
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
    };

    const createChart = () => {
        if (canvas) {
            const ctx = canvas.getContext('2d');
            if (chartInstance) {
                chartInstance.destroy();
            }

            const tempdat = JSON.parse(JSON.stringify(data))

            chartInstance = new Chart(ctx, {
                type: 'doughnut',
                data: tempdat,
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

    $effect(() => {
        if(data) { createChart() }
    })
</script>

<div style="height: 400px; width: 100%;">
    <canvas bind:this={canvas}></canvas>
</div>
