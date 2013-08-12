express = require 'express'
config = require './config'
RedisStore = require('connect-redis')(express)

redis =

app = express()
app.set('title', 'I Owe YOU!')
app.use(express.bodyParser());


require('./controllers/entry')(app)
require('./controllers/auth')(app)

app.listen config.app.port
console.log 'Listening on port '+config.app.port