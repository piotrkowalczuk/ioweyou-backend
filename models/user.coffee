db = require '../db'

module.exports =
  create: (fields, next) ->
    create(fields, next)
  getById: (id, next) ->
    getById(id, next)
  getBy: (fieldName, value, next) ->
    getBy(fieldName, value, next)
  getByFacebookId: (value, next) ->
    getByFacebookId(value, next)
  getFriends: (userId, next) ->
    getFriends(userId, next)
  findAllByFacebookIds: (facebookIds, next) ->
    findAllByFacebookIds(facebookIds, next)

create = (fields, next) ->
  db.postgres('user')
    .insert(fields)
    .returning('id')
    .exec next

getBy = (fieldName, value, next) ->
  db.postgres()
    .from('user')
    .select(
      'user.id',
      'user.username',
      'user.first_name',
      'user.last_name',
      'user.email',
      'sau.uid'
    )
    .join('user_social as sau', 'sau.user_id', '=', 'user.id', 'left')
    .where(fieldName, value)
    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)


getById = (id, next) ->
  getBy('user.id', id, next)


getByFacebookId = (value, next) ->
  getBy('sau.uid', value, next)

findAllByFacebookIds = (facebookIds, next) ->
  db.postgres()
    .from('user')
    .select(
      'user.id',
      'user.username',
      'user.first_name',
      'user.last_name',
      'user.email',
      'sau.uid'
    )
    .join('user_social as sau', 'sau.user_id', '=', 'user.id', 'left')
    .whereIn('sau.uid', facebookIds)
    .exec next

getFriends = (id, next) ->
  subQuery = db.postgres.raw('
    SELECT uf.creator_id AS friend
    FROM user_friendship uf, "user" u
    WHERE u.id = uf.friend_id AND u.id = '+id+'
    UNION
    SELECT uf.friend_id AS friend
    FROM user_friendship uf, "user" u
    WHERE u.id = uf.creator_id AND u.id = '+id
  )

  db.postgres()
    .from('user')
    .select(
      'user.id',
      'user.username',
      'user.first_name',
      'user.last_name',
      'user.email',
      'sau.uid'
    )
    .whereIn('user.id', subQuery)
    .join('user_social as sau', 'sau.user_id', '=', 'user.id', 'left')
    .orderBy('user.last_name', 'ASC')
    .exec (error, reply) ->
      if not error
        next(reply)
      else
        next(false)
