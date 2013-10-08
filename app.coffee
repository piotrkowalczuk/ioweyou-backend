express = require 'express'
config = require './config'
expressValidator = require 'express-validator'

app = express()
app.set('title', 'I Owe YOU!')

app.use express.bodyParser()
app.use expressValidator()

require('./controllers/entry')(app)
require('./controllers/auth')(app)
require('./controllers/user')(app)

app.listen config.app.port
console.log 'Listening on port '+config.app.port