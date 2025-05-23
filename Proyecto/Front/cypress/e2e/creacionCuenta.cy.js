describe('Atencion al cliente', () => {
	it('Crear una cuenta desde rol de atencion al cliente', () => {
		cy.fixture('cliente').then((cliente) => {
			cy.visit('/');
			cy.get('#email').type('userAtencion');
			cy.get('#pass').type('_6-YV[$ow$|{xA4#');
			cy.get('#role').select('usuario');
			cy.get('form').submit();

			// Expandir el menú
			cy.get('main').find('button').first().click();

			cy.get('[href="/CuentaQ"]').click();

			cy.url().should('include', '/CuentaQ');

			cy.get('[placeholder="Nombre"]').type(cliente.nombre);
			cy.get('[placeholder="Apellido"]').type(cliente.apellido);
			cy.get('[placeholder="CUI"]').type(cliente.cui);
			cy.get('[placeholder="Teléfono"]').type(cliente.telefono);
			cy.get('[placeholder="Correo"]').type(cliente.correo);
			cy.get('[placeholder="Edad"]').type(cliente.edad);
			cy.contains('Seleccione género').parent().select(cliente.genero);
			cy.get('[placeholder="Dirección"]').type(cliente.direccion);

			cy.get('#file-input').attachFile(cliente.foto);

			cy.contains('Siguiente').click();

			cy.get('#tipo-cuenta').select(cliente.tipoCuenta);
			cy.get('#pregunta-seguridad').select(cliente.preguntaSeguridad);
			cy.get('#monto').type(cliente.monto);
			cy.get('#respuesta').type(cliente.respuesta);
			// Interceptar la alerta
			cy.on('window:alert', (alertText) => {
				expect(alertText).to.equal('Cuenta completa creada exitosamente');
			});

			cy.contains('Submit').click();
		});
	});
});
