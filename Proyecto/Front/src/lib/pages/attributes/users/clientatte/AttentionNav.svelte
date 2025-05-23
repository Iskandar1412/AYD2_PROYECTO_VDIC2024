<script>
	import { Link } from 'svelte-routing';

	let activeMenu = $state(null);
	function toggleMenu(menu) {
		activeMenu = activeMenu === menu ? null : menu;
	}
</script>

<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'new-account'}
		style:width="100%"
		onclick={() => toggleMenu('new-account')}
	>
		<i class="bx bx-user-check mr-3 text-lg"></i>
		<span class="text-sm">Cuentas</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'new-account'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'new-account'}>
		<li class="mb-4">
			<Link
				to="/CuentaQ"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Registrar Cuenta en Q
			</Link>
		</li>
		<li class="mb-4">
			<Link
				to="/CuentaExt"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Registrar Cuenta en $
			</Link>
		</li>
	</ul>
</li>
<span class="text-gray-400 font-bold">GESTIONES</span>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'client-data'}
		style:width="100%"
		onclick={() => toggleMenu('client-data')}
	>
		<i class="bx bx-group mr-3 text-lg"></i>
		<span class="text-sm">Clientes</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'client-data'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'client-data'}>
		<li class="mb-4">
			<Link
				to="/DatosCliente"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Actualización Datos
			</Link>
		</li>
	</ul>
</li>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'regisencu-menu'}
		style:width="100%"
		onclick={() => toggleMenu('regisencu-menu')}
	>
		<i class="bx bx-box mr-3 text-lg"></i>
		<span class="text-sm">Registros/Encuestas</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'regisencu-menu'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'regisencu-menu'}>
		<li class="mb-4">
			<Link
				to="/Satisfaccion"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Encuesta de Satisfacción
			</Link>
		</li>
		<li class="mb-4">
			<Link
				to="/Quejas"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Registro de Quejas
			</Link>
		</li>
	</ul>
</li>
<span class="text-gray-400 font-bold">SERVICIOS</span>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'tarjetas-menu'}
		style:width="100%"
		onclick={() => toggleMenu('tarjetas-menu')}
	>
		<i class="bx bx-card mr-3 text-lg"></i>
		<span class="text-sm">Tarjetas</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'tarjetas-menu'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'tarjetas-menu'}>
		<li class="mb-4">
			<Link
				to="/NovTarjeta"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Nueva Tarjeta
			</Link>
		</li>
		<li class="mb-4">
			<Link
				to="/BloqTarjeta"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Bloqueo Tarjeta
			</Link>
		</li>
	</ul>
</li>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'solicitudes-menu'}
		style:width="100%"
		onclick={() => toggleMenu('solicitudes-menu')}
	>
		<i class="bx bxl-blogger mr-3 text-lg"></i>
		<span class="text-sm">Solicitudes</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'solicitudes-menu'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'solicitudes-menu'}>
		<li class="mb-4">
			<Link
				to="/Prestamos"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Prestamos
			</Link>
		</li>
		<li class="mb-4">
			<Link
				to="/CancelarServicios"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Cancelación de Servicios
			</Link>
		</li>
	</ul>
</li>