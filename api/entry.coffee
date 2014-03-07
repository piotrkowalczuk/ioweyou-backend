moment = require 'moment'
config = require '../config'
auth = require '../lib/auth'
entryTable = require '../models/entry'
userTable = require '../models/user'
userFriendshipTable = require '../models/userFriendship'
userManager = require '../managers/user'
clientTable = require '../models/userClient'
session = require '../models/session'


module.exports = (app) ->
  #GET
  app.get '/entry', auth.tokenAuth, filters, list
  app.get '/entry/summary', auth.tokenAuth, filters, summary
  app.get '/entry/count', auth.tokenAuth, filters, count
  app.get '/entry/:id', auth.tokenAuth, one
  #PUT
  app.put '/entry',auth.tokenAuth, create
  #POST
  app.post '/entry/:id', auth.tokenAuth, modify
  app.post '/entry/accept/:id', auth.tokenAuth, accept
  app.post '/entry/reject/:id', auth.tokenAuth, reject
  #DELETE
  app.delete '/entry/:id', auth.tokenAuth, remove


filters = (req, res, next) ->

  res.locals.filters = {}

  if req.query.limit
    req.assert('limit', {
    max: 'Maximum value is 100.',
    isInt: 'Integer expected.'
    }).max(100).isInt()

  if req.query.offset
    req.assert('offset', 'Invalid offset format. Expected integer').isInt()

  if req.query.from
    req.assert('from', 'Invalid from date format. Expected POSIX time').isInt()

  if req.query.to
    req.assert('to', 'Invalid from date format. Expected POSIX time').isInt()

  if req.query.contractor
    req.assert('contractor', 'Invalid contractor format. Expected integer.').isInt()

  if req.query.status
    req.assert('status', 'Invalid status format. Expected integer.').isInt()

  if req.query.order
    req.assert('order', 'Invalid order format. Expected asc or desc.').isIn(['asc', 'desc'])

  if req.validationErrors()
    res.status(404).send(req.validationErrors())
  else
    res.locals.filters =
      limit: req.query.limit
      offset: req.query.offset
      from: Number(req.query.from)
      to: Number(req.query.to)
      contractor: req.query.contractor
      status: req.query.status
      order: req.query.order
      name: req.query.name

    next()

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
        res.status(404).send("Not Found.")
  else
    res.status(400).send()

list = (req, res) ->
  entryTable.getAll req.query.uid, res.locals.filters, (entries) ->
    if entries
      res.header "Content-Type", "application/json"
      res.send(entries)
    else
      res.status(404).send()

summary = (req, res) ->
  console.log(res.locals.filters);
  entryTable.getSummary req.query.uid, res.locals.filters, (error, summary) ->
    if not error
      res.header "Content-Type", "application/json"
      res.send JSON.stringify({summary: summary})
    else
      res.status(404).send("Not Found.")

count = (req, res) ->
  entryTable.getCount req.query.uid, res.locals.filters, (count) ->
    if count
      res.header "Content-Type", "application/json"
      res.send(count)
    else
      res.status(404).send("Not Found.")

create = (req, res) ->
  req.checkBody('name', 'Nazwa nie może być pusta.').notEmpty()
  req.checkBody('value', 'Kwota nie może być pusta. Może być liczbą całkowitą lub zmienno przecinkową.').isFloat()
  req.checkBody('includeMe', '').isInt()
  req.checkBody('contractors', 'Musisz wybrać chociaż jedną osobę.').notEmpty()

  if not req.validationErrors()

    userId = req.body.uid
    name = req.body.name
    contractors = req.body.contractors
    description = req.body.description
    value = req.body.value / (contractors.length + parseInt(req.body.includeMe))

    userFriendshipTable.friendshipsExists userId, contractors, (exists) ->
      if exists
        for contractor in contractors
          userTable.getById contractor, (dbContractor) =>
            if dbContractor
              values =
                name: name
                description: description
                value: value
                status: 0
                lender_id: userId
                debtor_id: dbContractor.id
                created_at: moment().format('YYYY-MM-DD HH:mm:ss')
                updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

              entryTable.create values, (statusCode, entryId)->
                if statusCode is not 200
                  res.status(statusCode).send {entryId: entryId}
                else
                  session.getUserData userId, (user) ->
                    subject = "#{user.first_name} #{user.last_name} add dept to you."

                    clientTable.getByUserId dbContractor.id, (client)->
                      if client
                        res.apn.createMessage()
                          .device(client.token)
                          .alert(subject)
                          .set('entryId', entryId)
                          .send()

                    res.mailer.send 'mails/creatingConfirmation', {
                      to: dbContractor.email,
                      subject: subject,
                      name: name,
                      description: description,
                      value: value,
                      contractor: dbContractor
                    }, (error) ->

            else
              res.status(404).send("Not Found.")

          res.status(200).send {isCreated: true}
      else
        res.status(404).send("Not Found.")
  else
    res.status(400).send(req.validationErrors(true))


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

              clientTable.getByUserId entry.lender_id, (client)->
                if client
                  res.apn.createMessage()
                    .device(client.token)
                    .alert(subject)
                    .send()

              res.mailer.send 'mails/acceptance', {
                to: lender.email,
                subject: subject,
                entry: entry,
                debtor: debtor
              }, (error) ->

      res.status(statusCode).send {isModified: isModified}
  else
    res.status(400).send()


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

              clientTable.getByUserId entry.lender_id, (client)->
                if client
                  res.apn.createMessage()
                    .device(client.token)
                    .alert(subject)
                    .send()

              res.mailer.send 'mails/rejection', {
                to: lender.email,
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
    res.status(400).send()


modify = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()
  req.checkBody('name', 'Nazwa nie może być pusta.').notEmpty()
  req.checkBody('value', 'Kwota nie może być pusta. Może być liczbą całkowitą lub zmienno przecinkową').isFloat()

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

              subject = "#{debtor.first_name} #{debtor.last_name} modified entry."

              clientTable.getByUserId debtor.id, (client)->
                if client
                  res.apn.createMessage()
                    .device(client.token)
                    .alert(subject)
                    .send()

              res.mailer.send 'mails/modification', {
                to: debtor.email,
                subject: subject,
                entry: entry,
                debtor: debtor
                }, (error) ->

      res.status(statusCode).send {isModified: isModified}
  else
    res.status(400).send(req.validationErrors())



