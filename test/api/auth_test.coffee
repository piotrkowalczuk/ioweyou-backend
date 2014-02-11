app = require('../../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../../config'
serverHelper = require '../helpers/server'

server = null

describe 'api/auth', ->

  before (done)->
    server = serverHelper.createServer(done)

  after (done)->
    server.close()
    done()

  it "should return code 401, when POST \"/login\" route without credentials", (done)->
    http.get serverHelper.getHeaders("POST", "/login"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()
