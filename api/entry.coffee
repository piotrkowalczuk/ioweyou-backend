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
  app.get '/entries', auth.tokenAuth, filters, list
  app.get '/entries/summary', auth.tokenAuth, filters, summary
  app.get '/entries/count', auth.tokenAuth, filters, count

  app.get '/entry/:id', auth.tokenAuth, one
  app.put '/entry/:id', auth.tokenAuth, modify
  app.post '/entry',auth.tokenAuth, create
  app.post '/entry/accept/:id', auth.tokenAuth, accept
  app.post '/entry/reject/:id', auth.tokenAuth, reject
  app.delete '/entry/:id', auth.tokenAuth, remove


filters = (req, res, next) ->

  res.locals.filters = {}

  if req.query.limit
    req.assert('limit', {
      isLength: 'Maximum value is 100.',
      isInt: 'Integer expected.'
    }).isLength(0, 100).isInt()

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

  if req.validationErrors()
    res.status(400).send()
  else
    entryId = req.params.id
    userId = res.locals.user.ioweyouId

    entryTable.getUserEntryById userId, entryId, (error, entry) ->
      res.header "Content-Type", "application/json"
      if error
        res.status(500).send()
      else if entry
        res.send entry
      else
        res.status(404).send()


list = (req, res) ->
  userId = res.locals.user.ioweyouId

  entryTable.getAll userId, res.locals.filters, (error, entries) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send {error: 'Internal Server Error.'}
    else if entries
      res.send entries
    else
      res.status(404).send {error: "Not Found."}


summary = (req, res) ->
  userId = res.locals.user.ioweyouId

  entryTable.getSummary userId, res.locals.filters, (error, summary) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send({error: 'Internal Server Error.'})
    else if summary
      res.send JSON.stringify({summary: summary})
    else
      res.status(404).send {error: 'Not Found.'}


count = (req, res) ->
  userId = res.locals.user.ioweyouId

  entryTable.getCount userId, res.locals.filters, (error, count) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send("Internal Server Error.")
    else if count
      res.send(count)
    else
      res.status(404).send("Not Found.")


create = (req, res) ->
  req.checkBody('name', 'Nazwa nie może być pusta.').notEmpty()
  req.checkBody('value', 'Kwota nie może być pusta. Może być liczbą całkowitą lub zmienno przecinkową.').isFloat()
  req.checkBody('includeMe', '').isInt()
  req.checkBody('contractors', 'Musisz wybrać chociaż jedną osobę.').notEmpty()

  if req.validationErrors()
    res.status(400).send()
  else
    userId = res.locals.user.ioweyouId
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

              entryTable.create values, (error, entry)->
                if error
                  res.status(404).send()
                else
                  session.getUserData userId, (user) ->
                    subject = "#{user.first_name} #{user.last_name} add dept to you."

                    clientTable.getByUserId dbContractor.id, (error, client)->
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
                      contractor: user
                    }, (error) ->

            else
              res.status(404).send()

          res.status(201).send {isCreated: true}
      else
        res.status(404).send()


accept = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if req.validationErrors()
    res.status(400).send()
  else
    entryId = req.params.id
    userId = req.body.uid

    entryTable.accept userId, entryId, (error, isModified) ->
      if isModified
        entryTable.getById entryId, (error, entry)->
          if error
            res.status(400).send()
          else
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
      if error
        res.status(400).send {isModified: isModified}
      else
        res.status(200).send {isModified: isModified}


reject = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if req.validationErrors()
    res.status(400).send()
  else
    entryId = req.params.id
    userId = req.body.uid

    entryTable.reject userId, entryId, (error, isModified) ->
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

      if error
        res.status(500).send()
      else
        res.status(200).send {isModified: isModified}


remove = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if req.validationErrors()
    res.status(400).send(req.validationErrors())
  else
    entryId = req.params.id
    userId = res.locals.user.ioweyouId

    entryTable.remove userId, entryId, (error, isModified) ->
      res.header "Content-Type", "application/json"
      if error
        res.status(500).send()
      else if isModified
        res.status(204).send {isModified: isModified}
      else
        res.status(404).send()


modify = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()
  req.checkBody('name', 'Nazwa nie może być pusta.').notEmpty()
  req.checkBody('value', 'Kwota nie może być pusta. Może być liczbą całkowitą lub zmienno przecinkową').isFloat()

  if req.validationErrors()
    res.status(400).send(req.validationErrors())
  else
    entryId = req.params.id
    userId = res.locals.user.ioweyouId
    name = req.body.name
    description = req.body.description
    value = req.body.value

    values =
      name: name
      description: description
      value: value
      updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

    entryTable.modify userId, entryId, values, (error, isModified) ->
      if isModified
        entryTable.getById entryId, (error, entry)->
          if error
            res.status(400).send()
          else
            userTable.getById entry.lender_id, (lender)->
              userTable.getById entry.debtor_id, (debtor)->

                subject = "#{lender.first_name} #{lender.last_name} modified entry."

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
                  lender: lender
                  }, (error) ->

      if error
        res.status(500).send()
      else
        res.status(200).send {isModified: isModified}



