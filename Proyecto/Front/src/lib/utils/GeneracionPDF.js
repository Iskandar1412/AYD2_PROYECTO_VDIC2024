import jsPDF from "jspdf";
import { PathBackend } from "../stores/host";

export async function generacionPDF(message, empleado, tipo, cuenta, monto) {
    try {
        const doc = new jsPDF();
        doc.setFont("helvetica", "normal");
        doc.text(new Date().toString(), 10, 10);

        doc.setFontSize(16);
        doc.setFont("helvetica", "bold");
        doc.text(`${tipo}`, 105, 20, { align: "center" });

        doc.setFontSize(12);
        doc.text("Número de cuenta:", 10, 40);
        doc.setFont("helvetica", "normal");
        doc.text(`${cuenta}`, 60, 40);

        doc.setFont("helvetica", "bold");
        doc.text("Tipo de transacción:", 10, 50);
        doc.setFont("helvetica", "normal");
        doc.text(`${tipo}`, 60, 50);

        doc.setFont("helvetica", "bold");
        doc.text("Fecha y hora:", 10, 60);
        doc.setFont("helvetica", "normal");
        doc.text(`${new Date().toISOString()}` , 60, 60);

        doc.setFont("helvetica", "bold");
        doc.text("Monto:", 10, 70);
        doc.setFont("helvetica", "normal");
        doc.text(`${monto}`, 60, 70);
        
        doc.setFont("helvetica", "bold");
        doc.text("Nombre del empleado:", 10, 80);
        doc.setFont("helvetica", "normal");
        doc.text(`${empleado.nombres} ${empleado.apellidos}`, 60, 80);
        
        doc.setFont("helvetica", "bold");
        doc.text("Firma del empleado:", 10, 100);
        const proxyURL = `${PathBackend}/administracion/proxy-image?url=${encodeURIComponent(empleado.link_firma)}`;

        fetch(proxyURL)
        .then(response => response.blob())
        .then(blob => {
            const url = URL.createObjectURL(blob);
            // Añadir la imagen al PDF
            doc.addImage(url, 'JPEG', 60, 95, 50, 20);
            doc.save(`${tipo}_${message.trans_id}.pdf`);
        })
        .catch(err => {
            console.error('Error al cargar la imagen:', err);
        });

        
        // doc.save(`${tipo}_${message.trans_id}.pdf`);
    } catch (error) {
        console.error("Error generando el PDF:", error);
        alert("Error generando el PDF. Por favor, verifica los datos.");
    }
}

export async function generacionCambioMoneda(message, empleado, tipo, cuenta, monto) {
    try {
        const doc = new jsPDF();
        doc.setFont("helvetica", "normal");
        doc.text(new Date().toString(), 10, 10);

        doc.setFontSize(16);
        doc.setFont("helvetica", "bold");
        doc.text(`${tipo}`, 105, 20, { align: "center" });

        doc.setFontSize(12);
        doc.text("Número de cuenta:", 10, 40);
        doc.setFont("helvetica", "normal");
        doc.text(`${cuenta}`, 60, 40);

        doc.setFont("helvetica", "bold");
        doc.text("Tipo de transacción:", 10, 50);
        doc.setFont("helvetica", "normal");
        doc.text(`${tipo}`, 60, 50);

        doc.setFont("helvetica", "bold");
        doc.text("Fecha y hora:", 10, 60);
        doc.setFont("helvetica", "normal");
        doc.text(`${new Date().toISOString()}` , 60, 60);

        doc.setFont("helvetica", "bold");
        doc.text("Monto:", 10, 70);
        doc.setFont("helvetica", "normal");
        doc.text(`${monto}`, 60, 70);
        
        doc.setFont("helvetica", "bold");
        doc.text("Nombre del empleado:", 10, 80);
        doc.setFont("helvetica", "normal");
        doc.text(`${empleado.nombres} ${empleado.apellidos}`, 60, 80);
        
        doc.setFont("helvetica", "bold");
        doc.text("Firma del empleado:", 10, 100);
        const proxyURL = `${PathBackend}/administracion/proxy-image?url=${encodeURIComponent(empleado.link_firma)}`;

        fetch(proxyURL)
        .then(response => response.blob())
        .then(blob => {
            const url = URL.createObjectURL(blob);
            // Añadir la imagen al PDF
            doc.addImage(url, 'JPEG', 60, 95, 50, 20);
            doc.save(`${tipo}_${message.trans_id}.pdf`);
        })
        .catch(err => {
            console.error('Error al cargar la imagen:', err);
        });

        
        // doc.save(`${tipo}_${message.trans_id}.pdf`);
    } catch (error) {
        console.error("Error generando el PDF:", error);
        alert("Error generando el PDF. Por favor, verifica los datos.");
    }
}