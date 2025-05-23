<script>
	import { Link } from "svelte-routing";
    import { isAuthenticated, user } from "../../stores/auth";
	import { sidebarOpen } from "../../stores/sidevar";
	import CashierNav from "./users/cashier/CashierNav.svelte";
	import SupervisorNav from "./users/supervisor/SupervisorNav.svelte";
	import AttentionNav from "./users/clientatte/AttentionNav.svelte";
	import SysAdminNav from "./users/sysadmin/SysAdminNav.svelte";
    let tipo = $state()
    $effect.pre(() => {
        if($user.rol === 'supervisor') {
            tipo = "SUPERVISOR"
        } else if ($user.rol === 'administrador') {
            tipo = "SYS ADMIN"
        } else if ($user.rol === 'cajero') {
            tipo = "CASHIER"
        } else if ($user.rol === 'atencion') {
            tipo = "CLIENT AT"
        }
    })
	
    let isSidebarOpen = $state();
	sidebarOpen.subscribe((value) => {
		isSidebarOpen = value;
	});
</script>

<!--sidenav -->
{#if $user && $isAuthenticated}
<div
	class="fixed left-0 top-0 w-64 h-full bg-[#f8f4f3] p-4 z-50 sidebar-menu transition-transform"
	class:-translate-x-full={!isSidebarOpen}
>
	<!-- Contenido del sidebar -->
	<Link to="/home" class="flex items-center pb-4 border-b border-b-gray-800">
		<h2 class="font-bold text-2xl">
			AYD <span class="bg-[#f84525] text-white px-2 rounded-md">2</span>
		</h2>
	</Link>
	<ul class="mt-4">
        <span class="text-gray-400 font-bold">
            {tipo}
        </span>
        <li class="mb-1 group">
            <Link
                to="/home"
                class="flex font-semibold items-center py-2 px-4 text-gray-900 hover:bg-gray-950 hover:text-gray-100 rounded-md group-[.active]:bg-gray-800 group-[.active]:text-white group-[.selected]:bg-gray-950 group-[.selected]:text-gray-100"
            >
                <i class="ri-home-2-line mr-3 text-lg"></i>
                <span class="text-sm">Dashboard</span>
            </Link>
        </li>
        {#if $user.rol === 'cajero'}
        <!-- ------------------------------------------------------------------------ -->
            <CashierNav />
        <!-- ------------------------------------------------------------------------ -->
        {:else if $user.rol === 'atencion'}
        <!-- ------------------------------------------------------------------------ -->
            <AttentionNav />
        <!-- ------------------------------------------------------------------------ -->
        {:else if $user.rol === 'administrador'}       
        <!-- ------------------------------------------------------------------------ -->
            <SysAdminNav />
        <!-- ------------------------------------------------------------------------ -->
        {:else if $user.rol === 'supervisor'}       
        <!-- ------------------------------------------------------------------------ -->
            <SupervisorNav />
        <!-- ------------------------------------------------------------------------ -->
        {/if}       
	</ul>
</div>
<div class="fixed top-0 left-0 w-full h-full bg-black/50 z-40 md:hidden sidebar-overlay"></div>
{/if}
<!-- end sidenav -->