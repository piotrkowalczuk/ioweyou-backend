db = require '../db'

module.exports =
  getById: (id, next) ->
    getById(id, next)
  getBy: (fieldName, value, next) ->
    getBy(fieldName, value, next)
  getByFacebookId: (value, next) ->
    getByFacebookId(value, next)
  getFriends: (userId, next) ->
    getFriends(userId, next)
  friendshipsExists: (userId, friendsIds, next) ->
    friendshipsExists(userId, friendsIds, next)

getBy = (fieldName, value, next) ->
  db.postgres()
    .from('auth_user')
    .select(
      'auth_user.id',
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'sau.uid'
    )
    .join('social_auth_usersocialauth as sau', 'sau.user_id', '=', 'auth_user.id', 'left')
    .where(fieldName, value)
    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)


getById = (id, next) ->
  getBy('auth_user', id, next)


getByFacebookId = (value, next) ->
  getBy('sau.uid', value, next)


getFriends = (id, next) ->
  subQuery = db.postgres.Raw('
    SELECT uf.creator_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.friend_id AND au.id = '+id+'
    UNION
    SELECT uf.friend_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.creator_id AND au.id = '+id
  )

  db.postgres()
    .from('auth_user')
    .select(
      'auth_user.id',
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'sau.uid'
    )
    .whereIn('auth_user.id', subQuery)
    .join('social_auth_usersocialauth as sau', 'sau.user_id', '=', 'auth_user.id', 'left')
    .orderBy('auth_user.last_name', 'ASC')
    .exec (error, reply) ->
      if not error
        next(reply)
      else
        next(false)


friendshipsExists = (userId, friendsIds, next) ->
  db.postgres()
    .from('user_friendship')
    .select(
      'id'
    )
    .where (sub) ->
      sub.whereIn('creator_id', friendsIds)
        .andWhere('friend_id', userId)
    .orWhere (sub) ->
      sub.whereIn('friend_id', friendsIds)
        .andWhere('creator_id', userId)
    .exec (error, reply) ->
      if not error and reply.length > 0
        next(true)
      else
        next(false)