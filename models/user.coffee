db = require '../db'

module.exports =
  getById: (id) ->
    getById(id)
  getBy: (fieldName, value) ->
    getBy(fieldName, value)
  getFriends: (userId) ->
    getFriends(userId)

getById = (id) ->

  db()
    .from('auth_user')
    .select(
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'sau.uid'
    )
    .join('social_auth_usersocialauth as sau', 'sau.user_id', '=', 'auth_user.id', 'left')
    .where('auth_user.id', id)

getBy = (fieldName, value) ->

  db()
    .from('auth_user')
    .select(
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'social_auth_usersocialauth.uid'
    )
    .join('social_auth_usersocialauth', 'social_auth_usersocialauth.user_id', '=', 'auth_user.id', 'left')
    .where('auth_user.'+fieldName, value)

getFriends = (id) ->

  subQuery = db.Raw('
    SELECT uf.creator_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.friend_id AND  au.id = '+id+'
    UNION
    SELECT uf.friend_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.creator_id AND  au.id = '+id
  )

  db()
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
