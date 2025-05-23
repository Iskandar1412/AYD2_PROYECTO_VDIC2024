const { MailToSend } = require('../controllers/AdminMail.controller')

const router = require('express').Router()
// POST 
router.post('/email', MailToSend)

module.exports = router;