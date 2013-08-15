db = require '../db'

module.exports =
  getById: (id) ->
    getById(id)
  getBy: (fieldName, value) ->
    getBy(fieldName, value)
  getByFacebookId: (value) ->
    getByFacebookId(value)
  getFriends: (userId) ->
    getFriends(userId)


getById = (id) ->
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
    .where('auth_user.id', id)


getBy = (fieldName, value) ->
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


getByFacebookId = (value) ->
  getBy('sau.uid', value)


getFriends = (id) ->
  subQuery = db.postgres.Raw('
    SELECT uf.creator_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.friend_id AND  au.id = '+id+'
    UNION
    SELECT uf.friend_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.creator_id AND  au.id = '+id
  )

  db.postgres()
    .from('auth_user')
    .select(
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'sau.uid'
    )
    .whereIn('auth_user.id', subQuery)
    .join('social_auth_usersocialauth as sau', 'sau.user_id', '=', 'auth_user.id', 'left')
