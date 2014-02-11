app = require('../../app.coffee').app
config = require '../../config'

module.exports =
  createServer: (done) ->
    createServer(done)
  getHeaders: (type, path) ->
    getHeaders(type, path)

createServer = (done)->
  server = require('http').createServer(app)
  server.listen config.app.port, (error, result)->
    if error
      done error
    else
      done()

getHeaders = (type, path)->
  headers =
    "host": "127.0.0.1",
    "port": config.app.port,
    "path": path,
    "method": type,
    "headers": {}