import { defineConfig } from 'cypress'

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:5173',
  },
})


/* const { defineConfig } = require('cypress');
const vitePreprocessor = require('@cypress/vite-dev-server');

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      on('dev-server:start', (options) => vitePreprocessor(options));
      return config;
    },
    baseUrl: 'http://localhost:3000', // Asegúrate de que coincida con tu puerto Vite
  },
}); */
