express = require 'express'
config = require './config'
expressValidator = require 'express-validator'
mailer = require 'express-mailer'

app = express()
app.set('title', 'I Owe YOU!')
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

app.use express.bodyParser()
app.use expressValidator()

mailer.extend app, config.mailer

require('./controllers/entry')(app)
require('./controllers/auth')(app)
require('./controllers/user')(app)

app.listen config.app.port
console.info 'Listening on port '+config.app.port