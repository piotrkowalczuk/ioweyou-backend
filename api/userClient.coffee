config = require '../config'
auth = require '../lib/auth'
clientTable = require '../models/userClient'

module.exports = (app) ->
  app.put '/user-client/add-or-create', auth.tokenAuth, addOrCreate

addOrCreate = (req, res) ->
  req.assert('name', 'Invalid device name').notEmpty()
  req.assert('token', 'Invalid device token').notEmpty()

  if not req.validationErrors()

    userId = res.locals.user.ioweyouId

    clientTable.getByUserId userId, (error, client) ->

      values =
        user_id: userId
        name: req.body.name
        token: req.body.token

      if client
        clientTable.modify client.id, values, (error, isModified) ->
          if error
            res.status(500).send()
          else if isModified
            res.header "Content-Type", "application/json"
            res.send JSON.stringify({isModified: isModified})

      else
        clientTable.create values, (error, isCreated) ->
          if error
            res.status(500).send()
          else if isCreated
            res.header "Content-Type", "application/json"
            res.send JSON.stringify({isCreated: isCreated})

  else
    res.send(400).send()

