express = require 'express'
config = require './config'
expressValidator = require 'express-validator'
mailer = require 'express-mailer'
validator = require './lib/validator'


app = exports.app = express()
app.set('title', 'I Owe YOU!')
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

app.use express.bodyParser()
app.use expressValidator({
  errorFormatter: validator.errorFormatter
})

mailer.extend app, config.mailer

#Controllers
require('./api/entry')(app)
require('./api/auth')(app)
require('./api/user')(app)
require('./api/userClient')(app)

if config.apn.env in ["prod", "dev"]
  apn = require('./lib/apn').apn
  
  #Events
  require('./event/applePushNotificationsSubscriber')()