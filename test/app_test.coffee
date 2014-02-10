app = require('../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../config'
helpers = require './helpers'


server = null

describe 'app', ->

  before (done)->
    server = helpers.createServer(done)

  after (done)->
    server.close()
    done()

  it 'should exist', (done)->
    should.exist(server)
    done()

  it "should return code 404", (done)->
    headers =
      host: "127.0.0.1",
      port: config.app.port,
      path: '/',
      method: "POST",
      headers: {}

    http.get headers, (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(404)
      res.on 'end', ()->
        done()
