db = require '../db'
config = require '../config'

module.exports =
  sessionExists: (token, next) ->
    sessionExists(token, next)
  getUserFieldValue: (token, next) ->
    getUserFieldValue(token, next)
  getUserData: (token, next) ->
    getUserData(token, next)
  setUserData: (uid, userData) ->
    setUserData(uid, userData)
  getUserId: (uid, next) ->
    getUserId(uid, next)


sessionExists = (token, next) ->
  db.redis.get token, (error, reply) ->
    if not error and reply
      db.redis.expire token, config.session.expiration
      next(true)
    else
      next(false)

getUserFieldValue = (token, field, next) ->
  db.redis.get token, (error, reply) ->
    if not error and reply
      db.redis.expire token, config.session.expiration
      user = JSON.parse(reply)
      next(user[field])
    else
      next(false)


getUserData = (token, next) ->
  db.redis.get token, (error, reply) ->
    if not error and reply
      db.redis.expire token, config.session.expiration
      next(JSON.parse(reply))
    else
      next(false)


setUserData = (token, userData) ->
  db.redis.set token, JSON.stringify(userData)
  db.redis.expire token, config.session.expiration


getUserId = (token, next) ->
  getUserFieldValue(token, 'ioweyouId', next)