pg = require('pg')
config = require('../config')

#---- postgres ----
client = new pg.Client(config.database.conString)
client.connect()

module.exports =
  getById: (id, next) ->
    getById(id, next)
  getBy: (fieldName, value, next) ->
    getBy(fieldName, value, next)
  getFriendsByUserId: (userId, next) ->
    getFriendsByUserId(userId, next)

getById = (id, next) ->
  sql = 'SELECT au.username, au.first_name, au.last_name, au.email, sau.uid
        FROM auth_user AS au
        LEFT JOIN social_auth_usersocialauth AS sau ON sau.user_id = au.id
        WHERE au.id=$1;'

  runQuery sql, id, next

getBy = (fieldName, value, next) ->
  getUserFields (results) ->
    userFields = results.rows

    fieldFound = false
    for field in userFields
      if field.field_name == fieldName
        fieldFound = true
        break

    throw new Error "Invalid field name" unless fieldFound

    sql = 'SELECT au.username, au.first_name, au.last_name, au.email, sau.uid
          FROM auth_user AS au
          LEFT JOIN social_auth_usersocialauth AS sau ON sau.user_id = au.id
          WHERE au.'+fieldName+'=$1;'

    runQuery sql, [value], next

getUserFields = (next) ->
  fieldSql = 'SELECT column_name as field_name
              FROM information_schema.columns
              WHERE table_name=\'auth_user\';'
  runQuery fieldSql, null, next


getFriendsByUserId = (userId, next) ->
  sql = 'SELECT au.first_name, au.last_name, au.username
        FROM user_friendship as uf
        LEFT JOIN auth_user as au ON au.id = uf.friend_id
        WHERE creator_id=$1'

  runQuery sql, [userId], next

runQuery = (sql, args, next) ->
  callback = (err, results) ->
    if err
      return console.error('Error running query', err)
    next(results)

  if args?
    client.query sql, args, callback
  else
    client.query sql, callback
