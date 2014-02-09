app = require('../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../config'

defaultGetOptions = (path)->
  options =
    "host": "127.0.0.1",
    "port": config.app.port,
    "path": path,
    "method": "POST",
    "headers": {}

  options


server = null

describe 'app', ->

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

  it 'should exist', (done)->
    should.exist(server)
    done()

  it "should return code 404", (done)->
    headers = defaultGetOptions '/'
    http.get headers, (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(404)
      res.on 'end', ()->
        done()
