app = require('../../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../../config'
helpers = require '../helpers'

server = null

describe 'controllers/auth', ->

  before (done)->
    server = helpers.createServer(done)

  after (done)->
    server.close()
    done()

  it "should return code 401, when POST \"/login\" route without credentials", (done)->
    http.get helpers.getHeaders("POST", "/login"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()
