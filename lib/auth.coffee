express = require 'express'
request = require 'request'
session = require '../models/session'
config = require '../config'

module.exports =
  tokenAuth: (req, res, next) ->
    tokenAuth(req, res, next)


tokenAuth = (req, res, next) ->

  req.session = session
  req.assert('uid', 'Invalid uid').notEmpty().isInt()
  req.assert('apiToken', 'Invalid uid').isUUIDv4()

  if not req.validationErrors()
    req.session.getUserApiToken req.param('uid'), (apiToken) ->
      if apiToken is req.param('apiToken')
        next()
      else
        res.status(403).send 'Forbiden'
  else
    res.status(500).send 'Bad Request'