app = require('../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../config'

defaultGetOptions = (path)->
  options =
    "host": "localhost",
    "port": config.port,
    "path": path,
    "method": "GET",
    "headers": {}

  options


server = null

describe 'app', ->

  before (done)->
    server = require('http').createServer(app)
    server.listen config.port, (error, result)->
      if error
        done error
      else
        done()

  after (done)->
    server.close()
    done()

  it 'should exist', (done)->
    should.exist(app)
    done()

  it 'should be listening at localhost:8000', (done)->
    headers = defaultGetOptions '/'
    http.get headers, (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(200)
      res.on 'end', ()->
        done()
