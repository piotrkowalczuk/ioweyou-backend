pg = require('pg')
config = require('../config')
auth = require('../lib/auth')

#---- postgres ----
client = new pg.Client(config.database.conString)
client.connect()

module.exports = (app) ->
  app.get '/entry/:id', auth.tokenAuth, getById
  app.get '/entries', auth.tokenAuth, getAll
  app.get '/entries/summary/:userId', getSummary


generateResponse = (req, res, sql) ->
  client.query sql, (err, result) ->
    if(err)
      return console.error('error running query', err)

    json = JSON.stringify(result.rows)
    res.header "Content-Type", "application/json; charset=utf-8"
    res.end(json)


getById = (req, res) ->
  entryId = req.params.id
  sql = 'SELECT ee.*,
            debtor.first_name as debtor_first_name,
            debtor.last_name as debtor_last_name,
            debtor.username as debtor_username,
            lender.first_name as lender_first_name,
            lender.last_name as lender_last_name,
            lender.username as lender_username
            FROM entry_entry as ee
            LEFT JOIN auth_user as debtor ON debtor.id = ee.debtor_id
            LEFT JOIN auth_user as lender ON lender.id = ee.lender_id
            WHERE ee.status < 3 AND ee.id = '+entryId+';'

  generateResponse(req, res, sql)


getAll = (req, res) ->
  sql = 'SELECT ee.*,
           debtor.first_name as debtor_first_name,
           debtor.last_name as debtor_last_name,
           debtor.username as debtor_username,
           lender.first_name as lender_first_name,
           lender.last_name as lender_last_name,
           lender.username as lender_username
           FROM entry_entry as ee
           LEFT JOIN auth_user as debtor ON debtor.id = ee.debtor_id
           LEFT JOIN auth_user as lender ON lender.id = ee.lender_id
           WHERE ee.status < 3
           ORDER BY created_at DESC;'

  generateResponse(req, res, sql)


getSummary = (req, res) ->
  userId = req.params.userId
  sql = 'SELECT ee.* FROM entry_entry as ee WHERE ee.status < 3 AND (ee.debtor_id = '+userId+' OR ee.lender_id = '+userId+');'

  client.query sql, (err, result) ->
    if(err)
      return console.error('error running query', err)

    summary = 0.0

    i = 0
    for entry in result.rows
      if entry.debtor_id.toString() is userId
        summary = parseFloat(summary) - parseFloat(entry.value)
        console.log i+": "+summary+" - "+entry.value
      if entry.lender_id.toString() is userId
        summary = parseFloat(summary) + parseFloat(entry.value)
        console.log i+": "+summary+" - "+entry.value
      i = i + 1

    json = JSON.stringify({"summary": summary.toFixed(2)})
    res.header "Content-Type", "application/json; charset=utf-8"
    res.end(json)

