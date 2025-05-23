<script>
	import { Link } from 'svelte-routing';

	let activeMenu = $state(null);
	function toggleMenu(menu) {
		activeMenu = activeMenu === menu ? null : menu;
	}
</script>

<span class="text-gray-400 font-bold">GESTIONES</span>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'empleados-nav'}
		style:width="100%"
		onclick={() => toggleMenu('empleados-nav')}
	>
		<i class="bx bx-group mr-3 text-lg"></i>
		<span class="text-sm">Empleados</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'empleados-nav'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'empleados-nav'}>
		<li class="mb-4">
			<Link
				to="/CreateEmpleado"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Crear Empleado
			</Link>
		</li>
		<!-- <li class="mb-4">
			<Link
				to="/EliminacionEmpleado"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Eliminar Empleado
			</Link>
		</li> -->
		<li class="mb-4">
			<Link
				to="/RolesEmpleados"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Roles Empleados
			</Link>
		</li>
		<!-- <li class="mb-4">
			<Link
				to="/ChangePassUser"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Cambio Contraseña
			</Link>
		</li> -->
		<li class="mb-4">
			<Link
				to="/GestionEmpleados"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Gestion Empleados
			</Link>
		</li>
	</ul>
</li>
<li class="mb-1 group">
	<button
		class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md"
		class:selected={activeMenu === 'seguridad-nav'}
		style:width="100%"
		onclick={() => toggleMenu('seguridad-nav')}
	>
		<i class="bx bx-lock mr-3 text-lg"></i>
		<span class="text-sm">Copias de Seguridad</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'seguridad-nav'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'seguridad-nav'}>
		<li class="mb-4">
			<Link
				to="/SecurityCopy"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Copias de Seguridad
			</Link>
		</li>
	</ul>
</li>