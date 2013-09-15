db = require '../db'

module.exports =
  getById: (id, next) ->
    getById(id, next)
  getUserEntryById: (userId, entryId, next) ->
    getUserEntryById(userId, entryId, next)
  getAll: (id, next) ->
    getAll(id, next)
  getSummary: (userId, next) ->
    getSummary(userId, next)
  create: (fields, next) ->
    create(fields, next)
  modify: (id, fields, next) ->
    modify(id, fields, next)


getEntryQuery = ()->
  db.postgres()
    .from('entry_entry')
    .select(
      'entry_entry.*',
      'debtor.first_name as debtor_first_name',
      'debtor.last_name as debtor_last_name',
      'debtor.username as debtor_username',
      'lender.first_name as lender_first_name',
      'lender.last_name as lender_last_name',
      'lender.username as lender_username'
    )
    .join('auth_user as debtor', 'debtor.id', '=', 'entry_entry.debtor_id', 'left')
    .join('auth_user as lender', 'lender.id', '=', 'entry_entry.lender_id', 'left')

create = (fields, next) ->

  db.postgres('entry_entry')
    .insert(fields)
    .exec (error, reply) ->
      if not error
        next(true)
      else
        next(false)

modify = (id, fields, next) ->

  db.postgres('entry_entry')
    .update(fields)
    .where('entry_entry.id', '=', id)
    .exec (error, reply) ->
      if not error
        next(true)
      else
        next(false)


getById = (id, next) ->

  getEntryQuery()
    .where('entry_entry.id', id)
    .where('entry_entry.status', '<', '3')
    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)

getUserEntryById = (userId, entryId, next) ->

  getEntryQuery()
    .where('entry_entry.id', entryId)
    .where('entry_entry.status', '<', '3')
    .where (sub) ->
      sub.where('debtor.id', userId)
      .orWhere('lender.id', userId)

    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)

getAll = (id, next) ->

  getEntryQuery()
    .where('entry_entry.status', '<', '3')
    .where('debtor.id', id)
    .orWhere('lender.id', id)
    .orderBy('entry_entry.created_at', 'DESC')
    .exec (error, reply) ->
      if not error
        next(reply)
      else
        next(false)

getSummary = (userId, next) ->

  db.postgres()
    .from('entry_entry')
    .select('entry_entry.*')
    .where('entry_entry.status', '<', '3')
    .where (sub) ->
      sub.where('debtor_id', userId)
        .orWhere('lender_id', userId)
    .exec (error, reply) ->
      if not error
        summary = 0.0
        i = 0
        for row in reply
          if row.debtor_id.toString() is userId
            summary = parseFloat(summary) - parseFloat(row.value)
          if row.lender_id.toString() is userId
            summary = parseFloat(summary) + parseFloat(row.value)
          i = i + 1

        next(JSON.stringify({"summary": summary.toFixed(2)}))
      else
        next(false)