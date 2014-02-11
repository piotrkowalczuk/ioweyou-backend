app = require('../../app.coffee').app
config = require '../../config'

module.exports =
  clearDatabase: (done) ->
    clearDatabase(done)


clearDatabase = (done)->
  server = require('http').createServer(app)
  server.listen config.app.port, (error, result)->
    if error
      done error
    else
      done()