<script>
	import { onMount } from 'svelte';
	import { isAuthenticated, user } from '../stores/auth';
	import { navigate } from 'svelte-routing';
	import { sidebarOpen } from '../stores/sidevar';
    import Sidenav from './attributes/Sidenav.svelte';
	import Navbar from './attributes/Navbar.svelte';

	let { Component } = $props();

	onMount(() => {
		console.log($user);
		
	});

	$effect.pre(() => {
		if ($isAuthenticated === false) {
			navigate('/');
		}
	});

    let isSidebarOpen = $state();
	sidebarOpen.subscribe((value) => {
		isSidebarOpen = value;
	});
</script>

<svelte:head>
	<link rel="preconnect" href="https://fonts.bunny.net" />
	<link
		href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap"
		rel="stylesheet"
	/>
	<link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet" />
	<link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet" />
	<script src="https://cdn.tailwindcss.com"></script>
</svelte:head>

{#if $user && $isAuthenticated}
<main 
    class="transition-all bg-gray-200 min-h-screen"
    class:ml-64={isSidebarOpen}
    class:ml-0={!isSidebarOpen}
>
	<Sidenav />
	<Navbar />

	<div class="p-6">
        <Component />
    </div>
</main>
{/if}
