describe('Administrador', () => {
	it('Crear un empleado', () => {
		cy.fixture('empleado').then((empleado) => {
			cy.visit('/');
			cy.get('#email').type('Iskandar');
			cy.get('#pass').type('9:DxD}O=X<m,u5Nl');
			cy.get('#role').select('Administrador');

			cy.get('form').submit();

			cy.get('[accept=".ayd"]').attachFile('IskandarKey.ayd');

			cy.contains('Subir y Continuar').click();

			// Expandir el menú
			cy.get('main').find('button').first().click();

			cy.get('[href="/CreateEmpleado"]').click();

			cy.url().should('include', '/CreateEmpleado');

      cy.get('#nombres').type(empleado.nombres);
      cy.get('#apellidos').type(empleado.apellidos);
      cy.get('#edad').type(empleado.edad);
      cy.get('#dpi').type(empleado.dpi);
      cy.get('#telefono').type(empleado.telefono);
      cy.get('#usuario').type(empleado.usuario);
      cy.get('#correo').type(empleado.correo);
      cy.get('#genero').select(empleado.genero);
      cy.get('#estadoCivil').select(empleado.estadoCivil);

      cy.contains('Subir foto ').find('input').first().attachFile(empleado.foto)
      cy.contains('Subir firma ').find('input').first().attachFile(empleado.firma)
      cy.contains('Subir papelería ').find('input').first().attachFile(empleado.papeleria)

      cy.contains('Crear Usuario').click()

      // Interceptar la alerta
			cy.on('window:alert', (alertText) => {
				expect(alertText).to.equal('Usuario creado exitosamente');
			});
		});
	});
});
