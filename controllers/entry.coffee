config = require '../config'
auth = require '../lib/auth'
entryTable = require '../models/entry'
userTable = require '../models/user'
moment = require 'moment'


module.exports = (app) ->
  #GET
  app.get '/entry/:id', auth.tokenAuth, one
  app.get '/entries', auth.tokenAuth, list
  app.get '/entries/summary', auth.tokenAuth, summary
  #PUT
  app.put '/entry',auth.tokenAuth, create
  #POST
  app.post '/entry/:id', auth.tokenAuth, modify
  app.post '/entry/accept/:id', auth.tokenAuth, accept
  app.post '/entry/reject/:id', auth.tokenAuth, reject
  #DELETE
  app.delete '/entry/:id', auth.tokenAuth, remove

one = (req, res) ->
  entryId = req.params.id
  userId = req.query.uid

  req.session.getUserId userId, (userId) ->
    entryTable.getUserEntryById userId, entryId, (entry) ->
      if entry
        res.header "Content-Type", "application/json"
        res.send(entry)
      else
        res.status(404).send()


list = (req, res) ->
  userId = req.query.uid
  req.session.getUserId userId, (userId) ->
    if userId
      entryTable.getAll userId, (entries) ->
        if entries
          res.header "Content-Type", "application/json"
          res.send(entries)
        else
          res.status(404).send()


summary = (req, res) ->
  userId = req.query.uid
  entryTable.getSummary userId, (summary) ->
    if summary
      res.header "Content-Type", "application/json"
      res.send(summary)
    else
      res.status(404).send()


create = (req, res) ->

  values =
    name: req.body.name
    description: req.body.description
    value: req.body.value
    status: req.body.status
    lender_id: req.body.lender_id
    debtor_id: req.body.debtor_id
    created_at: moment().format('YYYY-MM-DD HH:mm:ss')
    updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

  entry.create values, (isCreated)->
    if isCreated
      res.send('The entry has been created.')
    else
      res.status(500).send()


accept = (req, res) ->
  entryId = req.params.id
  userId = req.body.uid

  entryTable.accept userId, entryId, (statusCode, isModified) ->
      res.status(statusCode).send {isModified: isModified}


reject = (req, res) ->
  entryId = req.params.id
  userId = req.body.uid

  entryTable.reject userId, entryId, (statusCode, isModified) ->
    res.status(statusCode).send {isModified: isModified}


remove = (req, res) ->
  entryId = req.params.id
  userId = req.query.uid

  entryTable.remove userId, entryId, (statusCode, isModified) ->
    res.status(statusCode).send {isModified: isModified}


modify = (req, res) ->
  entryId = req.params.id
  userId = req.body.uid

  values =
    name: req.body.name
    description: req.body.description
    value: req.body.value
    status: req.body.status
    updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

  entryTable.modify userId, entryId, values, (statusCode, isModified) ->
    res.status(statusCode).send {isModified: isModified}




