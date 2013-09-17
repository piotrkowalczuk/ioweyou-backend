express = require 'express'
request = require 'request'
session = require '../models/session'
config = require '../config'

module.exports =
  tokenAuth: (req, res, next) ->
    tokenAuth(req, res, next)


tokenAuth = (req, res, next) ->
  req.session = session

  queryApiToken = req.param('apiToken')
  queryUID = req.param('uid')

  if queryApiToken and queryUID
    req.session.getUserApiToken queryUID, (apiToken) ->
      if apiToken is queryApiToken
        next()
      else
        res.status(403).send 'Forbiden'
  else
    res.status(500).send 'Bad Request'