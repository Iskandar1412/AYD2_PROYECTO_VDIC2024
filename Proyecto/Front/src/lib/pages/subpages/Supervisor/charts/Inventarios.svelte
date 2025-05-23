<script>
    import { Chart, registerables } from "chart.js";
    Chart.register(...registerables);

    let { data } = $props();
    let canvas;
    let chartInstance;

    const options = {
        responsive: true,
        maintainAspectRatio: false,
    };

    const createChart = () => {
        console.log("Data being passed to Chart.js:", data);

        if (canvas) {
            const ctx = canvas.getContext("2d");
            if (chartInstance) {
                chartInstance.destroy();
            }

            // Convertir snapshot a objeto estándar
            const plainData = JSON.parse(JSON.stringify(data));

            chartInstance = new Chart(ctx, {
                type: "line",
                data: plainData,
                options,
            });
        }
    };

    $effect(() => {
        if (data) {
            createChart();
        }
    });
</script>

<div style="height: 400px; width: 100%;">
    <canvas bind:this={canvas}></canvas>
</div>
