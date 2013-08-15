express = require 'express'
request = require 'request'
session = require '../models/session'
config = require '../config'

module.exports =
  tokenAuth: (req, res, next) ->
    tokenAuth(req, res, next)


tokenAuth = (req, res, next) ->
  req.session = session

  req.session.getUserApiToken req.query.uid, (apiToken) ->
    if apiToken is req.query.apiToken
      next()
    else
      res.status(403).send 'Forbiden'