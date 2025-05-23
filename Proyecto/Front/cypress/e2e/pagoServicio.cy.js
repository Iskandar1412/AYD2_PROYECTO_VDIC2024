describe('Test de Login Incorrecto', () => {
	it('Debe ingresar credenciales incorrectas y mostrar un mensaje de error', () => {
		cy.fixture('servicio').then((servicio) => {
			cy.visit('/');
			cy.get('#email').type('userAtencion');
			cy.get('#pass').type('_6-YV[$ow$|{xA4#');
			cy.get('#role').select('usuario');
			cy.get('form').submit();

			// Expandir el menú
			cy.get('main').contains('Gestiones').parent().click();

			cy.get('[href="/PagoServicios"]').click();

			cy.get('#cuentaUsuario').type(servicio.noCuenta);
			cy.get('#servicioSeleccionado').select(servicio.servicio);
			cy.get('#montoAPagar').type(servicio.monto);

      cy.contains('Realizar Gestión').click()
      // Interceptar la alerta
			cy.on('window:alert', (alertText) => {
				expect(alertText).to.equal('Servicio pagado exitosamente');
			});
		});
	});
});
