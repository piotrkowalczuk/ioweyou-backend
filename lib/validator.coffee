express = require 'express'
request = require 'request'
session = require '../models/session'
config = require '../config'

module.exports =
  errorFormatter: (param, message, value) ->
    errorFormatter(param, message, value)


errorFormatter = (param, message, value) ->
  namespace = param.split('.')
  root    = namespace.shift()
  formParam = root

  while(namespace.length)
    formParam += '[' + namespace.shift() + ']'

  result =
    param : formParam,
    message   : message,
    value : value

