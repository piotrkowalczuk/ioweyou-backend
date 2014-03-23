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
      if error
        next(error, null)
      else if reply.length is 1
        next(null, reply[0])
      else
        next()


getById = (id, next) ->
  getBy('uc.id', id, next)


getByUserId = (userId, next) ->
  getBy('uc.user_id', userId, next)


create = (fields, next) ->
  db.postgres('user_client')
    .insert(fields)
    .exec (error, reply) ->
      next(error, reply)


modify = (id, fields, next) ->
  db.postgres('user_client')
    .update(fields)
    .where('id', '=', id)
    .exec (error, reply) ->
      next(error, reply)