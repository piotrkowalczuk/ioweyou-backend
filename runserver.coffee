app = require('./app').app
config = require './config'
http = require 'http'

server = http.createServer(app)
server.listen config.app.port, (error, result)->
  if error
    console.info error
  else
    console.info "Listening on port #{config.app.port}."