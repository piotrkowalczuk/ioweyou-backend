db = require '../db'


module.exports =
  getById: (id, next) ->
    getById(id, next)
  getByUserId: (userId, next) ->
    getByUserId(userId, next)
  create: (fields, next) ->
    create(fields, next)
  modify: (userId, fields, next) ->
    modify(userId, fields, next)


getBy = (fieldName, value, next) ->
  db.postgres()
    .from('user_client AS uc')
    .select(
      'uc.id',
      'uc.token',
      'uc.name',
      'uc.user_id'
    )
    .where(fieldName, value)
    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)


getById = (id, next) ->
  getBy('uc.id', id, next)


getByUserId = (userId, next) ->
  getBy('uc.user_id', userId, next)


create = (fields, next) ->

  db.postgres('user_client')
    .insert(fields)
    .exec (error, reply) ->
      if not error and reply > 0
        next(200)
      if error
        next(500)


modify = (id, fields, next) ->

  db.postgres('user_client')
    .update(fields)
    .where('id', '=', id)
    .exec (error, reply) ->
      if not error and reply > 0
        next(200, true)
      if not error and reply is 0
        next(200, false)
      else
        next(500)