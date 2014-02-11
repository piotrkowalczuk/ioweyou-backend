migrationManager = require './../managers/migration'
migrationTable = require './../models/migration'
fs = require 'fs'
Q = require 'q'


module.exports =
  initialize: (next) ->
    initialize(next)
  syncdb: (next) ->
    syncdb(next)
  cleardb: (next) ->
    cleardb(next)
  migrate: (next) ->
    migrate(next)


initialize = (next) ->
  migrationManager.initialize (message) ->
    next(message)


syncdb = (next) ->
  schema = require "../database/schema"
  schema.exec (error, result) ->
    next(error)

cleardb = (next) ->
  clear = require "../database/clear"
  clear.exec (error, result) ->
    next(error)


migrate = (next) ->
  migrations = []
  migrationsCount = 0
  migrationFiles = fs.readdirSync './database/migrations'

  for migrationFile in migrationFiles
    moduleName = migrationFile.substring(0, migrationFile.indexOf("."))
    migrations.push(require "../database/migrations/#{moduleName}")

  stop = Q ()->

  migrationTable.getVersion (currentVersion)->
    for migration in migrations
      if migration.version > currentVersion
        migrationsCount += 1
        do (migration) ->
          stop = stop.then () ->
            migration.exec().then () ->
              migrationManager.setVersion migration.version, (message) ->
                console.log message

    stop.then () ->
      if migrationsCount > 0
        next("Database migration completed successfully.")
      else
        next("Sync completed.")