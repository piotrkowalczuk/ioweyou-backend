express = require 'express'
request = require 'request'
session = require '../models/session'
config = require '../config'

module.exports =
  tokenAuth: (req, res, next) ->
    tokenAuth(req, res, next)


tokenAuth = (req, res, next) ->
  req.session = session

  token = req.header 'Authorization'

  if token and token isnt '(null)'
    req.session.getUserData token, (userData) ->
      if userData
        res.locals.user = userData;
        next()
      else
        res.status(403).send 'Forbidden'
  else
    res.status(401).send 'Unauthorized'
