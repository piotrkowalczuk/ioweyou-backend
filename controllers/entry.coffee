config = require '../config'
auth = require '../lib/auth'
entry = require '../models/entry'


module.exports = (app) ->
  app.get '/entry/:id', getById
  app.get '/entries/:id', getAll
  app.get '/entries/summary/:id', getSummary

getById = (req, res) ->
  entryId = req.params.id

  entry.getById(entryId).exec (error,response)->
    if not error
      res.send(response)
    else
      res.send(error)

getAll = (req, res) ->
  userId = req.params.id

  entry.getAll(userId).exec (error,response)->
    if not error
      res.send(response)
    else
      res.send(error)

getSummary = (req, res) ->
  userId = req.params.id

  entry.getSummary(userId).exec (error,response)->
    if not error
      summary = 0.0
      i = 0
      for row in response
        if row.debtor_id.toString() is userId
          summary = parseFloat(summary) - parseFloat(row.value)
        if row.lender_id.toString() is userId
          summary = parseFloat(summary) + parseFloat(row.value)
        i = i + 1

      json = JSON.stringify({"summary": summary.toFixed(2)})
      res.header "Content-Type", "application/json; charset=utf-8"
      res.end(json)
    else
      res.send(error)




