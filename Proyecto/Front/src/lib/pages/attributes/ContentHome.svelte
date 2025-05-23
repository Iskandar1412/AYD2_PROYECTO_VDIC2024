<script>
	import { user } from '../../stores/auth';
</script>

<svelte:head>
	<title>Home</title>
</svelte:head>
<!-- Content -->
<div class="p-6">
	<h2 class="text-3xl">
		<b>Welcome</b> <b class="text-blue-500">{$user.nombres} {$user.apellidos}</b>
	</h2>
</div>
<!-- End Content -->
