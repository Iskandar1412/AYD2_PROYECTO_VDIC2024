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
		<i class="bx bx-user mr-3 text-lg"></i>
		<span class="text-sm">Clientes</span>
		<i class="ri-arrow-right-s-line ml-auto" class:rotate-90={activeMenu === 'clientes-cashier'}
		></i>
	</button>
	<ul class="pl-7 mt-2" class:hidden={activeMenu !== 'clientes-cashier'}>
		<li class="mb-4">
			<Link
				to="/MostrarCliente"
				class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
			>
				Busqueda Cliente
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
					to="/PagoServicios"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Pago de Servicio
				</Link>
			</li>
			<li class="mb-4">
				<Link
					to="/PagoPrestamos"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Pago Prestamos
				</Link>
			</li>
			<li class="mb-4">
				<Link
					to="/RetiroDeposito"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Retiro/Depósito
				</Link>
			</li>
			<li class="mb-4">
				<Link
					to="/PagoTarjeta"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Pago Tarjeta
				</Link>
			</li>
			<li class="mb-4">
				<Link
					to="/CambioMoneda"
					class="text-gray-900 text-sm flex items-center hover:text-[#f84525] before:contents-[''] before:w-1 before:h-1 before:rounded-full before:bg-gray-300 before:mr-3"
				>
					Cambio de Moneda
				</Link>
			</li>
	</ul>
</li>
