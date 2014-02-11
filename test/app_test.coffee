app = require('../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../config'
serverHelper = require './helpers/server'


server = null

describe 'app', ->

  before (done)->
    server = serverHelper.createServer(done)

  after (done)->
    server.close()
    done()

  it 'should exist', (done)->
    should.exist(server)
    done()

  it "should return code 404", (done)->
    http.get serverHelper.getHeaders("POST", "/"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(404)
      res.on 'end', ()->
        done()
