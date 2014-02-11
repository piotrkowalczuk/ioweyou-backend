db = require '../db'
async = require 'async'
grunt = require 'grunt'
async = require 'async'
fs = require 'fs'

module.exports =
  load: (fileName, next) ->
    load(fileName, next)

load = (fileName, next) ->
  absoluteFilePath = process.cwd()+fileName

  if fs.existsSync absoluteFilePath
    fixtures = require absoluteFilePath

    async.eachSeries fixtures, insertData, (error)->
      if error
        grunt.verbose.errorlns error
      else
        grunt.verbose.oklns "Fixtures loaded successfully."
      next()
  else
    grunt.verbose.errorlns "File #{fileName} doesn't exist."
    next()

insertData = (fixture, next) ->
  db.postgres(fixture.table)
    .insert(fixture.data)
    .exec (error, reply) ->
      if error
        grunt.log.errorlns error

      next()