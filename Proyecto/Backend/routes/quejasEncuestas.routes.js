const { getQuejas,getEncuestasSatisfaccion,realizarQueja,realizarEncuesta } = require('../controllers/quejasEncuestas.controller');
const router = require('express').Router()

// GETS
router.get('/quejas',getQuejas);
router.get('/encuestas',getEncuestasSatisfaccion);

// PUTS


// POST
router.post('/regqueja',realizarQueja);
router.post('/regencuesta',realizarEncuesta);
module.exports = router;