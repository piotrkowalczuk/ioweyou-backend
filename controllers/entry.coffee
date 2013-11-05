moment = require 'moment'
config = require '../config'
auth = require '../lib/auth'
entryTable = require '../models/entry'
userTable = require '../models/user'
userManager = require '../managers/user'
device = require '../device'


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
  req.assert('id', 'Invalid entry ID').notEmpty().isInt()

  if not req.validationErrors()
    entryId = req.params.id
    userId = req.query.uid

    entryTable.getUserEntryById userId, entryId, (entry) ->
      if entry
        res.header "Content-Type", "application/json"
        res.send(entry)
      else
        res.status(404).send()
  else
    res.status(404).send()


list = (req, res) ->
  entryTable.getAll req.query.uid, (entries) ->
    if entries
      res.header "Content-Type", "application/json"
      res.send(entries)
    else
      res.status(404).send()


summary = (req, res) ->
  entryTable.getSummary req.query.uid, (summary) ->
    if summary
      res.header "Content-Type", "application/json"
      res.send(summary)
    else
      res.status(404).send()


create = (req, res) ->
  req.checkBody('name', 'Invalid name').notEmpty()
  req.checkBody('value', 'Invalid value').notEmpty().isFloat()

  if not req.validationErrors()

    userId = req.body.uid
    name = req.body.name
    contractors = req.body.contractors
    description = req.body.description
    value = req.body.value / (contractors.length + req.body.includeMe)

    userTable.friendshipsExists req.body.uid, userManager.usersToArrayOfIds(contractors), (exists) ->
      if exists
        for contractor in contractors
          values =
            name: name
            description: description
            value: value
            status: 0
            lender_id: userId
            debtor_id: contractor.id
            created_at: moment().format('YYYY-MM-DD HH:mm:ss')
            updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

          entryTable.create values, (statusCode, isCreated)->
            if statusCode is not 200
              res.status(statusCode).send {isCreated: isCreated}

        userTable.getById userId, (user) =>
          if user
            for contractor in contractors

              subject = "#{user.first_name} #{user.last_name} add dept to you."

              res.apn.createMessage()
                .device(device)
                .alert(subject)
                .send()

              res.mailer.send 'mails/creatingConfirmation', {
                to: contractor.email,
                subject: subject,
                name: name,
                description: description,
                value: value,
                contractor: contractor
              }, (error) ->
          else
            res.status(404).send()

        res.status(200).send {isCreated: true}
      else
        res.send(404).send()
  else
    res.send(404).send()


accept = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if not req.validationErrors()
    entryId = req.params.id
    userId = req.body.uid

    entryTable.accept userId, entryId, (statusCode, isModified) ->
      if isModified
        entryTable.getById entryId, (entry)->
          userTable.getById entry.lender_id, (lender)->
            userTable.getById entry.debtor_id, (debtor)->

              subject = "#{debtor.first_name} #{debtor.last_name} accepted your entry."

              res.apn.createMessage()
                .device(device)
                .alert(subject)
                .send()

              res.mailer.send 'mails/acceptance', {
                to: 'p.kowalczuk.priv@gmail.com',
                #to: lender.email,
                subject: subject,
                entry: entry,
                debtor: debtor
              }, (error) ->


      res.status(statusCode).send {isModified: isModified}
  else
    res.status(404).send()


reject = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if not req.validationErrors()
    entryId = req.params.id
    userId = req.body.uid

    entryTable.reject userId, entryId, (statusCode, isModified) ->
      if isModified
        entryTable.getById entryId, (entry)->
          userTable.getById entry.lender_id, (lender)->
            userTable.getById entry.debtor_id, (debtor)->

              subject = "#{debtor.first_name} #{debtor.last_name} rejected your entry."

              res.apn.createMessage()
                .device(device)
                .alert(subject)
                .send()

              res.mailer.send 'mails/rejection', {
                to: 'p.kowalczuk.priv@gmail.com',
                #to: lender.email,
                subject: subject,
                entry: entry,
                debtor: debtor
                }, (error) ->

      res.status(statusCode).send {isModified: isModified}
  else
    res.status(404).send()


remove = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if not req.validationErrors()
    entryId = req.params.id
    userId = req.query.uid

    entryTable.remove userId, entryId, (statusCode, isModified) ->
      res.status(statusCode).send {isModified: isModified}
  else
    res.status(404).send()


modify = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()
  req.checkBody('name', 'Invalid uid').notEmpty()
  req.checkBody('value', 'Invalid uid').notEmpty().isInt()

  if not req.validationErrors()
    entryId = req.params.id
    userId = req.body.uid
    name = req.body.name
    description = req.body.description
    value = req.body.value

    values =
      name: name
      description: description
      value: value
      updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

    entryTable.modify userId, entryId, values, (statusCode, isModified) ->
      if isModified
        entryTable.getById entryId, (entry)->
          userTable.getById entry.lender_id, (lender)->
            userTable.getById entry.debtor_id, (debtor)->

              subject = "#{debtor.first_name} #{debtor.last_name} modified your entry."

              res.apn.createMessage()
                .device(device)
                .alert(subject)
                .send()

              res.mailer.send 'mails/modification', {
                to: lender.email,
                subject: subject,
                entry: entry,
                debtor: debtor
                }, (error) ->

      res.status(statusCode).send {isModified: isModified}
  else
    res.status(400).send()



