app = require('../../app.coffee').app
should = require('chai').should()
http = require 'http'
config = require '../../config'
helpers = require '../helpers'

server = null

describe 'controllers/entry', ->

  before (done)->
    server = helpers.createServer(done)

  after (done)->
    server.close()
    done()

  it "should return code 401, when GET \"/entry\" route without credentials", (done)->
    http.get helpers.getHeaders("GET", "/entry"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when GET \"/entry/summary\" route without credentials", (done)->
    http.get helpers.getHeaders("GET", "/entry/summary"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when GET \"/entry/count\" route without credentials", (done)->
    http.get helpers.getHeaders("GET", "/entry/count"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when GET \"/entry/:id\" route without credentials", (done)->
    http.get helpers.getHeaders("GET", "/entry/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when PUT \"/entry\" route without credentials", (done)->
    http.get helpers.getHeaders("PUT", "/entry"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when POST \"/entry/:id\" route without credentials", (done)->
    http.get helpers.getHeaders("POST", "/entry/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when POST \"/entry/accept/:id\" route without credentials", (done)->
    http.get helpers.getHeaders("POST", "/entry/accept/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when POST \"/entry/reject/:id\" route without credentials", (done)->
    http.get helpers.getHeaders("POST", "/entry/reject/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()

  it "should return code 401, when DELETE \"/entry/:id\" route without credentials", (done)->
    http.get helpers.getHeaders("DELETE", "/entry/1"), (res)->
      res.on 'data', (chunk)->
        res.statusCode.should.eql(401)
      res.on 'end', ()->
        done()