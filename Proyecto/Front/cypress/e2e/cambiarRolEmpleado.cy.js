describe('Administrador rol', () => {
	it('Escoge el primer empleado y cambia el rol', () => {
		cy.visit('/');
		cy.get('#email').type('Iskandar');
		cy.get('#pass').type('9:DxD}O=X<m,u5Nl');
		cy.get('#role').select('Administrador');

		cy.get('form').submit();

		cy.get('[accept=".ayd"]').attachFile('IskandarKey.ayd');

		cy.contains('Subir y Continuar').click();

		// Expandir el menú
		cy.get('main').find('button').first().click();

		cy.get('[href="/RolesEmpleados"]').click();
		cy.url().should('include', '/RolesEmpleados');

		cy.get('table')
			.find('tbody tr:first-child td:nth-child(7) select')
			.select('Atención al Cliente')
			.should('have.value', 'atencion'); // Verifica que el valor se cambió
    
      cy.get('table')
			.find('tbody tr:first-child td:nth-child(8)')
      .click()

      cy.get('table') // Selecciona el input por ID
      .find('tbody tr:first-child td:nth-child(1)')
      .invoke('text') // Obtiene el valor del atributo "value"
      .then((valor) => {
        // Interceptar la alerta
        cy.on('window:alert', (alertText) => {
          expect(alertText).to.equal(`Rol Actualizado para el usuario: ${valor}`);
        });
      });
	});
});
