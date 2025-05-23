<script>
	import { navigate } from "svelte-routing";
	import { isAuthenticated, loginUser } from "../stores/auth";
	import { onMount } from "svelte";
	import { PathBackend } from "../stores/host";
	
	onMount(() => {
		if($isAuthenticated) {
			navigate('/home')
		} else {
			navigate('/')
		}
	})

	let emailText = $state();
	let passwordText = $state();
	let submit = $state(false);
	let showUploadModal = $state(false);
	let archivo = $state(null);
	let selectedRole = $state("");
	let userIdFrom2FA = $state();
	let cui2FA = $state();
	
	// usuario: "cashier"
	// nombres: "Jose Pablo"
	// apellidos: "Perez"
	// rol: "cajero"

	function clearInputs() {
		// emailText = "";
		// passwordText = "";
	}

	async function confirmUpload() {
		let url = selectedRole === 'supervisor' ? `${PathBackend}/administracion/loginsupfa` : 
			selectedRole === 'administrador' ? `${PathBackend}/administracion/loginadminfa` : "";

		let valuesToSend = selectedRole === 'supervisor' ? 
			{ id: userIdFrom2FA, password: archivo } :
			selectedRole === 'administrador' ? 
			{ id: userIdFrom2FA, password: archivo, cui: cui2FA } : "";

		console.log("ValuesToSend:", valuesToSend)
		if (archivo) {
			showUploadModal = false;
			await fetch(url, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify(valuesToSend)
			})
			.then(res => {
				if(!res.ok) {
					throw new Error('Error en la solicitud')
				}
				return res.json()
			})
			.then(data => {
				if(selectedRole === 'administrador' || selectedRole === 'supervisor') {
					if(selectedRole === "supervisor") {
						loginUser(data.message.empleado)
						navigate('/home')
					} else if(selectedRole === 'administrador') {
						// console.log("dat", data.message)
						loginUser(data.message)
						navigate('/home')
					}
				} else if(data.message.status === 'error') {
					throw new Error(data.message.message)
				}
				// console.log(data.message.empleado)
			})
			.catch(err => {
				alert(err)
			})
		} else {
			alert("Debe subir un archivo para continuar.");
		}
	}

	async function handleLoginForm(event) {
		event.preventDefault();
		submit = true;
		console.log("Usuario Rol:", selectedRole);

		const url = selectedRole === 'supervisor'
			? `${PathBackend}/administracion/loginsup`
			: selectedRole === 'administrador'
			? `${PathBackend}/administracion/loginadmin`
			: `${PathBackend}/administracion/login`;

		fetch(url, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ usuario: emailText, password: passwordText })
		})
		.then(res => {
			if(!res.ok) {
				throw new Error('Error en la solicitud')
			}
			return res.json()
		})
		.then(data => {
			// console.log("asdfasdf", data)
			if((selectedRole === 'administrador' && data.message.status === 'success') || (selectedRole === 'supervisor' && data.message.status === 'success')) {
				if(selectedRole === 'administrador') {
					showUploadModal = true;
					userIdFrom2FA = data.message.id_admin;
					cui2FA = data.message.cui;
				}
				if(selectedRole === 'supervisor') {
					showUploadModal = true;
					userIdFrom2FA = data.message.supervisor_id;
				}
				submit = false;
			} else if(selectedRole === 'usuario') {
				// console.log(data)
				if(data.message.status === "success") {
					loginUser(data.message)
					navigate('/home')
				} else {
					throw new Error(`Error en las credenciales del para el tipo de usuario: ${selectedRole}`)
				}
			}
			if(data.message.status === 'error') {
				throw new Error(data.message.message)
			}
		})
		.catch(err => {
			alert(err)
		})
		.finally(() => {
			clearInputs();
			submit = false;
		})
	}

	async function handleFileUpload(event) {
		let file = event.target.files[0];

		if (file && file.name.endsWith(".ayd")) {
			const reader = new FileReader();

			reader.onload = (e) => {
				const contenido = e.target.result;
				archivo = contenido
			};

			reader.onerror = () => {
				alert("Hubo un error al leer el archivo.");
				archivo = null;
			};

			reader.readAsText(file);
		} else {
			alert("Por favor, suba un archivo con extensión .ayd");
			archivo = null;
		}
	}
	
</script>

<div class="font-[sans-serif]">
	<div class="grid lg:grid-cols-3 md:grid-cols-2 items-center gap-4 h-full">
		<div class="max-md:order-1 lg:col-span-2 md:h-screen w-full bg-[#000842] md:rounded-tr-xl md:rounded-br-xl lg:p-12 p-8">
			<img
				src="https://readymadeui.com/signin-image.webp"
				class="lg:w-[70%] w-full h-full object-contain block mx-auto"
				alt="logo"
			/>
		</div>

		<div class="w-full p-6">
			<form class="form-login" onsubmit={handleLoginForm}>
				<div class="mb-8">
					<h3 class="text-gray-800 text-3xl font-extrabold">Inicio de Sesión</h3>
				</div>

				<div>
					<label for="email" class="text-gray-800 text-[15px] mb-2 block">User o Email</label>
					<div class="relative flex items-center">
						<input
							name="email"
							id="email"
							type="text"
							required
							class="w-full text-sm text-gray-800 bg-gray-100 focus:bg-transparent px-4 py-3.5 rounded-md outline-blue-600"
							bind:value={emailText}
							placeholder="Username or email address"
						/>
					</div>
				</div>

				<div class="mt-4">
					<label for="pass" class="text-gray-800 text-[15px] mb-2 block">Password</label>
					<div class="relative flex items-center">
						<input
							id="pass"
							name="password"
							type="password"
							required
							class="w-full text-sm text-gray-800 bg-gray-100 focus:bg-transparent px-4 py-3.5 rounded-md outline-blue-600"
							bind:value={passwordText}
							placeholder="Ingrese contraseña"
						/>
					</div>
				</div>

				<div class="mt-4">
					<label for="role" class="text-gray-800 text-[15px] mb-2 block">Seleccione Rol</label>
					<select
						id="role"
						bind:value={selectedRole}
						required
						class="w-full text-sm text-gray-800 bg-gray-100 px-4 py-3.5 rounded-md outline-blue-600"
					>
						<option value="" disabled selected>Seleccione un rol</option>
						<option value="usuario">Usuario Normal</option>
						<option value="supervisor">Supervisor</option>
						<option value="administrador">Administrador</option>
					</select>
				</div>

				<div class="mt-8">
					<button
						type="submit"
						class="w-full py-3 px-6 text-sm tracking-wide rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none button-login-form"
						disabled={!emailText || !passwordText || !selectedRole}
					>
						Ingresar
					</button>
				</div>
			</form>
		</div>
	</div>

	<!-- Modal para Subir Archivo -->
	{#if showUploadModal}
		<div class="fixed inset-0 bg-gray-800 bg-opacity-50 flex justify-center items-center">
			<div class="bg-white rounded-lg shadow-lg p-6 w-[400px]">
				<h2 class="text-lg font-bold mb-4">Autenticación Adicional</h2>
				<input type="file" accept=".ayd" onchange={handleFileUpload} class="mb-4" />
				<div class="flex justify-end gap-4">
					<button
						class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600"
						onclick={() => (showUploadModal = false)}
					>
						Cancelar
					</button>
					<button
						class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
						onclick={confirmUpload}
					>
						Subir y Continuar
					</button>
				</div>
			</div>
		</div>
	{/if}
</div>

<style lang="scss">
	.form-login {
		div {
			.button-login-form:disabled {
				opacity: 0.5;
				cursor: not-allowed;
			}
		}
	}
</style>
