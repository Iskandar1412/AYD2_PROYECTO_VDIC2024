import { writable } from "svelte/store";

export const dataToSendGraphIngentario = writable(null)
export const dineroQ = writable(0);
export const dineroD = writable(0);
export const resultados = writable([]);
export const filtroAnio = writable("");
export const filtroMes = writable("");
export const filtroTipo = writable("");