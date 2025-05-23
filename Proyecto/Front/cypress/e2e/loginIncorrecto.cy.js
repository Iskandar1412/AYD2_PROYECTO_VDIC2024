describe('Test de Login Incorrecto', () => {
  it('Debe ingresar credenciales incorrectas y mostrar un mensaje de error', () => {
    cy.visit('/');
    cy.get('#email').type('Pa123');
    cy.get('#pass').type('NoExiste123');
    cy.get('#role').select('usuario');
    
    cy.on('uncaught:exception', (text) => {
      expect(text).to.equal('Error en las credenciales del para el tipo de usuario: usuario');
    });
    cy.get('form').submit();
  })
})