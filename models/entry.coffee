db = require '../db'
moment = require 'moment'


module.exports =
  getById: (id, next) ->
    getById(id, next)
  getUserEntryById: (userId, entryId, next) ->
    getUserEntryById(userId, entryId, next)
  getAll: (userId, filters, next) ->
    getAll(userId, filters, next)
  getSummary: (userId, filters, next) ->
    getSummary(userId, filters, next)
  getCount: (userId, filters, next) ->
    getCount(userId, filters, next)
  create: (fields, next) ->
    create(fields, next)
  modify: (userId, entryId, fields, next) ->
    modify(userId, entryId, fields, next)
  accept: (userId, entryId, next) ->
    accept(userId, entryId, next)
  reject: (userId, entryId, next) ->
    reject(userId, entryId, next)
  remove: (userId, entryId, next) ->
    remove(userId, entryId, next)


getEntryQuery = ()->

  db.postgres()
    .from('entry')
    .select(
      'entry.*',
      'debtor.first_name as debtor_first_name',
      'debtor.last_name as debtor_last_name',
      'debtor.username as debtor_username',
      'lender.first_name as lender_first_name',
      'lender.last_name as lender_last_name',
      'lender.username as lender_username'
    )
    .join('user as debtor', 'debtor.id', '=', 'entry.debtor_id', 'left')
    .join('user as lender', 'lender.id', '=', 'entry.lender_id', 'left')


create = (fields, next) ->

  db.postgres('entry')
    .insert(fields)
    .returning('id')
    .exec (error, reply) ->
      if not error
        next(200, reply)
      else
        next(403)


modify = (userId, entryId, fields, next) ->

  db.postgres('entry')
    .update(fields)
    .where('id', '=', entryId)
    .where (sub) ->
      sub.where('debtor_id', userId)
        .orWhere('lender_id', userId)
    .exec (error, reply) ->
      if not error and reply > 0
        next(200, true)
      if not error and reply is 0
        next(200, false)
      else
        next(403)


getById = (id, next) ->

  getEntryQuery()
    .where('entry.id', id)
    .where('entry.status', '<', '3')
    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)


getUserEntryById = (userId, entryId, next) ->

  getEntryQuery()
    .where('entry.id', entryId)
    .where('entry.status', '<', '3')
    .where (sub) ->
      sub.where('debtor.id', userId)
      .orWhere('lender.id', userId)

    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)

getCount = (userId, filters, next) ->

  query = db.postgres()
    .from('entry')
    .count('id')
    .where('status', '!=', 3)
    .where (sub) ->
      sub.where('debtor_id', userId)
        .orWhere('lender_id', userId)

  if filters.from
    query.where('created_at', '>',  moment(filters.from).toISOString())

  if filters.to
    query.where('created_at', '<', moment(filters.to).toISOString())

  if filters.contractor
    query.where (sub) ->
      sub.where('debtor_id', filters.contractor)
        .orWhere('lender_id', filters.contractor)

  if filters.status
    query.where('status', '=', filters.status)

  if filters.name
    query.where('name', 'ilike', '%'+filters.name+'%')

  query.exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)

getAll = (userId, filters, next) ->

  query = getEntryQuery()
    .where (sub) ->
      sub.where('debtor_id', userId)
        .orWhere('lender_id', userId)
    .where('status', '!=', 3)
    .limit(filters.limit or 8)
    .offset(filters.offset or 0)
    .orderBy('created_at', filters.order or 'desc')

  if filters.from
    query.where('entry.created_at', '>',  moment(filters.from).toISOString())

  if filters.to
    query.where('entry.created_at', '<', moment(filters.to).toISOString())

  if filters.contractor
    query.where (sub) ->
      sub.where('debtor_id', filters.contractor)
        .orWhere('lender_id', filters.contractor)

  if filters.status
    query.where('status', '=', filters.status)

  if filters.name
    query.where('name', 'ilike', '%'+filters.name+'%')

  query.exec (error, reply) ->
    if not error
      next(reply)
    else
      next(false)



getSummary = (userId, filters, next) ->

  query = db.postgres()
    .from('entry')
    .select('entry.value', 'entry.lender_id', 'entry.debtor_id')
    .where('entry.status', '=', '1')
    .where (sub) ->
      sub.where('debtor_id', userId)
        .orWhere('lender_id', userId)

  if filters.from
    query.where('created_at', '>',  moment(filters.from).toISOString())

  if filters.to
    query.where('created_at', '<', moment(filters.to).toISOString())

  if filters.contractor
    query.where (sub) ->
      sub.where('debtor_id', filters.contractor)
        .orWhere('lender_id', filters.contractor)

  if filters.status
    query.where('status', '=', filters.status)

  if filters.name
    query.where('name', 'ilike', '%'+filters.name+'%')

  query.exec (error, reply) ->
    if not error
      summary = 0.0
      i = 0
      for row in reply
        if row.debtor_id is Number(userId)
          summary = parseFloat(summary) - parseFloat(row.value)
        if row.lender_id is Number(userId)
          summary = parseFloat(summary) + parseFloat(row.value)
        i = i + 1

      next error, summary.toFixed(2)
    else
      next error, null


accept = (userId, entryId, next) ->

  db.postgres('entry')
    .update({'accepted_at': new Date(), 'status': 1})
    .where('id', '=', entryId)
    .whereIn('status', [0,2]) # open|rejected
    .where('debtor_id', '=', userId)
    .exec (error, reply) ->
      if not error and reply > 0
        next(200, true)
      if not error and reply is 0
        next(200, false)
      else
        next(403)


reject = (userId, entryId, next) ->

  db.postgres('entry')
    .update({'rejected_at': new Date(), 'status': 2})
    .where('id', '=', entryId)
    .where('status', '=', 0) # open
    .where('debtor_id', '=', userId)
    .exec (error, reply) ->
      if not error and reply > 0
        next(200, true)
      if not error and reply is 0
        next(200, false)
      else
        next(403)


remove = (userId, entryId, next) ->

  db.postgres('entry')
    .update({'status': 3})
    .where('id', '=', entryId)
    .where('status', '=', 0) # open
    .where('lender_id', '=', userId)
    .exec (error, reply) ->
      if not error and reply > 0
        next(200, true)
      if not error and reply is 0
        next(200, false)
      else
        next(403)
