config = require '../config'
auth = require '../lib/auth'
user = require '../models/user'

module.exports = (app) ->
  app.get '/user/:id', getById
  app.get '/friends', getFriends

getById = (req, res) ->
  userId = req.params.id
  user.getById userId, (user) =>
    if user
      res.header "Content-Type", "application/json"
      res.send(user)
    else
      res.status(404).send()

getFriends = (req, res) ->
  user.getFriends req.query.uid, (friends) =>
    if friends
      res.header "Content-Type", "application/json"
      res.send(friends)
    else
      res.status(404).send()
