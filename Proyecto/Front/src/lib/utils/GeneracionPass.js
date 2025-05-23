export function generarContrasena(longitud = 16) {
    const caracteres = {
        mayusculas: "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        minusculas: "abcdefghijklmnopqrstuvwxyz",
        numeros: "0123456789",
        especiales: "!@#$%^&*()-_=+[]{}|;:,.<>?/"
    };

    const todosCaracteres = caracteres.mayusculas + caracteres.minusculas + caracteres.numeros + caracteres.especiales;

    let contrasena = "";

    contrasena += caracteres.mayusculas[Math.floor(Math.random() * caracteres.mayusculas.length)];
    contrasena += caracteres.minusculas[Math.floor(Math.random() * caracteres.minusculas.length)];
    contrasena += caracteres.numeros[Math.floor(Math.random() * caracteres.numeros.length)];
    contrasena += caracteres.especiales[Math.floor(Math.random() * caracteres.especiales.length)];

    for (let i = contrasena.length; i < longitud; i++) {
        contrasena += todosCaracteres[Math.floor(Math.random() * todosCaracteres.length)];
    }

    contrasena = contrasena.split("").sort(() => Math.random() - 0.5).join("");
    console.log(contrasena);
    return contrasena;
}

export function calcularNacimiento(edad) {
    const dateActual = new Date();
    const yearBirth = dateActual.getFullYear() - edad;

    const fechaNacimiento = new Date(yearBirth, dateActual.getMonth(), dateActual.getDate());

    const year = fechaNacimiento.getFullYear();
    const month = (fechaNacimiento.getMonth() + 1).toString().padStart(2, '0');
    const day = fechaNacimiento.getDate().toString().padStart(2, '0');

    return `${year}-${month}-${day}`;
}

export function calcularEdad(fechaNacimiento) {
    // Convertir la cadena de fecha de nacimiento en un objeto Date
    const nacimiento = new Date(fechaNacimiento);

    // Obtener la fecha actual
    const hoy = new Date();

    // Calcular la edad
    let edad = hoy.getFullYear() - nacimiento.getFullYear();

    // Ajustar si el cumpleaños no ha ocurrido aún este año
    const mesActual = hoy.getMonth();
    const diaActual = hoy.getDate();
    const mesNacimiento = nacimiento.getMonth();
    const diaNacimiento = nacimiento.getDate();

    if (mesActual < mesNacimiento || (mesActual === mesNacimiento && diaActual < diaNacimiento)) {
        edad--;
    }

    return edad;
}
