<!-- Reportes de desempeño laboral -->
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
        scales: {
            r: {
                angleLines: { display: false },
                suggestedMin: 0,
                suggestedMax: 5,
            },
        },
    };

    const createChart = () => {
        if (canvas) {
            const ctx = canvas.getContext('2d');
            if (chartInstance) {
                chartInstance.destroy();
            }

            const temp = JSON.parse(JSON.stringify(data))

            chartInstance = new Chart(ctx, {
                type: 'radar',
                data: temp,
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

    // $: if (data && chartInstance) {
    //     createChart();
    // }
    $effect(() => {
        if(data) { createChart() }
    })
</script>

<div style="height: 400px; width: 100%;">
    <canvas bind:this={canvas}></canvas>
</div>
