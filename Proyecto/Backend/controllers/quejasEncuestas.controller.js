const { getQuejas,getEncuestasSatisfaccion } = require('./quejasEncuestas/quejasEncuestas.controller.get')
const { } = require('./quejasEncuestas/quejasEncuestas.controller.put')
const { realizarQueja,realizarEncuesta } = require('./quejasEncuestas/quejasEncuestas.controller.post')

module.exports ={
    getQuejas,
    getEncuestasSatisfaccion,
    realizarQueja,
    realizarEncuesta
};