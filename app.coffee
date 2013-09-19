express = require 'express'
config = require './config'

app = express()
app.set('title', 'I Owe YOU!')
app.use(express.bodyParser());

require('./controllers/entry')(app)
require('./controllers/auth')(app)
require('./controllers/user')(app)

app.listen config.app.port
console.log "Listening on port #{config.app.port}"