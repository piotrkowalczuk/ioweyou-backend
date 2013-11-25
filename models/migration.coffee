db = require '../db'
moment = require 'moment'


module.exports =
  create: (fields, next) ->
    create(fields, next)
  modify: (fields, next) ->
    modify(fields, next)
  getVersion: (next) ->
    getVersion(next)


create = (fields, next) ->

  db.postgres('migration')
    .insert(fields)
    .exec (error, reply) ->
      next(error, reply)


modify = (fields, next) ->

  db.postgres('migration')
    .update(fields)
    .where('id', '=', 1)
    .exec (error, reply) ->
      next(error, reply)


getVersion = (next) ->

  db.postgres('migration')
    .select('version')
    .where('id', '=', 1)
    .exec (error, reply)->
      if not error
        next(reply[0]['version'])
      else
        next(null)


