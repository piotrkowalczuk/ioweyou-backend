db = require '../db'
moment = require 'moment'
knex = require 'knex'

module.exports =
  friendshipsExists: (userId, friendsIds, next) ->
    friendshipsExists(userId, friendsIds, next)
  createIfNotExists: (userId, friendId, next) ->
    createIfNotExists(userId, friendId, next)

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

createIfNotExists = (userId, friendId, next) ->

  values =
    created_at: moment().format('YYYY-MM-DD HH:mm:ss')
    creator_id: userId
    friend_id: friendId

  db.postgres('user_friendship')
    .whereNotExists () ->
      this.select(db.postgres.raw(1))
        .from('user_friendship')
        .where('creator_id', friendId)
        .andWhere('friend_id', userId)
    .whereNotExists () ->
      this.select(db.postgres.raw(1))
        .from('user_friendship')
        .where('friend_id', friendId)
        .andWhere('creator_id', userId)
    .then (rows)->
      if rows.length > 0
        db.postgres()
          .insert(values)
          .into('user_friendship')
          .returning('id')
          .exec next