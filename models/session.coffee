db = require '../db'

module.exports =
  getUserApiToken: (uid, next) ->
    getUserApiToken(uid, next)
  getUserFieldValue: (uid, next) ->
    getUserFieldValue(uid, next)
  getUserData: (uid, next) ->
    getUserData(uid, next)
  setUserData: (uid, userData) ->
    setUserData(uid, userData)
  getUserId: (uid, next) ->
    getUserId(uid, next)


getUserFieldValue = (uid, field, next) ->
  db.redis.get uid, (error, reply) ->
    if not error and reply
      user = JSON.parse(reply)
      next(user[field])
    else
      next(false)


getUserData = (uid, next) ->
  db.redis.get uid, (error, reply) ->
    if not error and reply
      next(JSON.parse(reply))
    else
      next(false)


setUserData = (uid, userData) ->
  db.redis.set uid, JSON.stringify(userData)


getUserApiToken = (uid, next) ->
  getUserFieldValue(uid, 'ioweyouToken', next)


getUserId = (uid, next) ->
  getUserFieldValue(uid, 'ioweyouId', next)