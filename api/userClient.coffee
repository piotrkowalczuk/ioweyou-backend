config = require '../config'
auth = require '../lib/auth'
clientTable = require '../models/userClient'

module.exports = (app) ->
  app.post '/user-client/add-or-create', auth.tokenAuth, addOrCreate

addOrCreate = (req, res) ->
  req.assert('name', 'Invalid device name').notEmpty()
  req.assert('token', 'Invalid device token').notEmpty()

  if not req.validationErrors()

    userId = req.body.uid

    clientTable.getByUserId userId, (client) ->

      values =
        user_id: userId
        name: req.body.name
        token: req.body.token

      if client
        clientTable.modify client.id, values, (statusCode, isModified) ->
          res.status(statusCode).send {isModified: isModified}

      else
        clientTable.create values, (statusCode, isCreated) ->
          res.status(statusCode).send {isCreated: isCreated}

  else
    res.send(400).send()

