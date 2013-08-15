config = require '../config'
auth = require '../lib/auth'
user = require '../models/user'

module.exports = (app) ->
  app.get '/user/:id', getById
  app.get '/user/friends/:id', getFriends

getById = (req, res) ->
  userId = req.params.id

  user.getById(userId).exec (error,response)->
    if not error
      res.send(response)
    else
      res.send(error)

getFriends = (req, res) ->
  userId = req.params.id
  user.getFriends(userId).exec (error,response)->
    if not error
      res.send(response)
    else
      res.send(error)
