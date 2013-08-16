config = require '../config'
auth = require '../lib/auth'
entryTable = require '../models/entry'
userTable = require '../models/user'
moment = require 'moment'


module.exports = (app) ->
  #GET
  app.get '/entry/:id', auth.tokenAuth, one
  app.get '/entries', auth.tokenAuth, list
  app.get '/entries/summary/:id', auth.tokenAuth, summary
  #PUT
  app.put '/entry',auth.tokenAuth, create
  #POST
  app.post '/entry/:id', auth.tokenAuth, modify


one = (req, res) ->
  entryId = req.params.id
  facebookUserId = req.query.uid

  req.session.getUserId facebookUserId, (userId) ->
    entryTable.getUserEntryById userId, entryId, (entry) ->
      if entry
        res.send(entry)
      else
        res.status(404).send()


list = (req, res) ->
  facebookUserId = req.query.uid

  req.session.getUserId facebookUserId, (userId) ->
    if userId
      entryTable.getAll userId, (entries) ->
        if entries
          res.send(entries)
        else
          res.status(404).send()


summary = (req, res) ->
  userId = req.params.id

  entryTable.getSummary userId, (summary) ->
    if summary
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


modify = (req, res) ->
  entryId = req.params.id
  facebookUserId = req.query.uid

  req.session.getUserId facebookUserId, (userId) ->
    if userId
      entryTable.getById entryId, (entry) ->
        if entry
          if userId is (entry.debtor_id or entry.lender_id)
            values =
              name: req.body.name
              description: req.body.description
              value: req.body.value
              status: req.body.status
              updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

            entryTable.modify entryId, values, (isModified) ->
              if isModified
                res.send('The entry has been changed.')
              else
                res.status(500).send()
          else
            res.status(404).send()
    else
      res.status(404).send()





