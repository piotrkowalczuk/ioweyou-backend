app = require('../../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../../config'

defaultGetOptions = (path)->
  options =
    "host": "127.0.0.1",
    "port": config.app.port,
    "path": path,
    "method": "POST",
    "headers": {}

  options


server = null

describe 'controllers/auth', ->

  before (done)->
    server = require('http').createServer(app)
    server.listen config.app.port, (error, result)->
      if error
        done error
      else
        done()

  after (done)->
    server.close()
    done()

  it "should return code 400, when call \"/login\" route without credentials", (done)->
    headers = defaultGetOptions '/login'
    http.get headers, (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(400)
      res.on 'end', ()->
        done()
