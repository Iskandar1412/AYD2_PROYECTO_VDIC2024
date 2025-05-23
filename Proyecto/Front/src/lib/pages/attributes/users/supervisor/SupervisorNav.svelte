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
		class:selected={activeMenu === 'clientes-cashier'}
		style:width="100%"
		onclick={() => toggleMenu('clientes-cashier')}
	>
		<i class="bx bx-group mr-3 text-lg"></i>
		<span class="text-sm">Empleados</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'clientes-cashier'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'clientes-cashier'}>
		<!-- <li class="mb-4">
			<Link
				to="/BusquedaEmpleados"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Busqueda de Empleado
			</Link>
		</li> -->
		<li class="mb-4">
			<Link
				to="/AdminRegister"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Registro Administrador de Sistemas
			</Link>
		</li>
		<li class="mb-4">
			<Link
				to="/GestionEmpleadosAdmin"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Gestion Empleados
			</Link>
		</li>
	</ul>
</li>
<span class="text-gray-400 font-bold">SERVICIOS</span>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'gestiones'}
		style:width="100%"
		onclick={() => toggleMenu('gestiones')}
	>
		<i class="bx bxl-blogger mr-3 text-lg"></i>
		<span class="text-sm">Gestiones</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'gestiones'}></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'gestiones'}>
		
			<li class="mb-4">
				<Link
					to="/Solicitud-banc"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Solicitudes
				</Link>
			</li>
			<li class="mb-4">
				<Link
					to="/Inventary-banc"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Inventarios Bancarios
				</Link>
			</li>
	</ul>
</li>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'reports-infor'}
		style:width="100%"
		onclick={() => toggleMenu('reports-infor')}
	>
		<i class="bx bx-task mr-3 text-lg"></i>
		<span class="text-sm">Reportes/Informes</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'reports-infor'}></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'reports-infor'}>
		
			<li class="mb-4">
				<Link
					to="/Satisfaccion-banc"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Encuestas de Satisfacción
				</Link>
			</li>
			<li class="mb-4">
				<Link
					to="/Quejas-banc"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Registro de Quejas
				</Link>
			</li>
			<li class="mb-4">
				<Link
					to="/Reports-banc"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Reportes
				</Link>
			</li>
	</ul>
</li>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'monitoring'}
		style:width="100%"
		onclick={() => toggleMenu('monitoring')}
	>
		<i class="bx bx-tachometer mr-3 text-lg"></i>
		<span class="text-sm">Monitoreo</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'monitoring'}></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'monitoring'}>
			<li class="mb-4">
				<Link
					to="/realTime"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Monitoreo a Tiempo Real
				</Link>
			</li>
	</ul>
</li>
