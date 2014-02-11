db = require '../db'
async = require 'async'
grunt = require 'grunt'

module.exports =
  exec: (next) ->
    exec(next)

exec = (next) ->
  operations = [
    dropUserClientTable,
    dropUserFriendshipTable,
    dropUserSocialTable,
    dropEntryCommentTable,
    dropAnnouncementConfirmationTable
    dropAnnouncementTable,
    dropEntryTable,
    dropUserTable,
    dropMigrationTable,
  ]

  async.series operations, (error, result) ->
    if error
      grunt.verbose.errorlns "#{result.length - 1} tables droped successfuly"
    else
      grunt.verbose.oklns "#{result.length} tables droped successfuly"

    next(error, result)


dropMigrationTable = (next) ->
  db.postgres.schema.dropTableIfExists('migration').then ()->
    grunt.verbose.oklns 'Migration table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropUserTable = (next) ->
  db.postgres.schema.dropTableIfExists('user').then ()->
    grunt.verbose.oklns 'User table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropUserClientTable = (next) ->
  db.postgres.schema.dropTableIfExists('user_client').then ()->
    grunt.verbose.oklns 'UserClient table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropUserFriendshipTable = (next) ->
  db.postgres.schema.dropTableIfExists('user_friendship').then ()->
    grunt.verbose.oklns 'UserFriendship table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropUserSocialTable = (next) ->
  db.postgres.schema.dropTableIfExists('user_social').then ()->
    grunt.verbose.oklns 'UserSocial table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropEntryTable = (next) ->
  db.postgres.schema.dropTableIfExists('entry').then ()->
    grunt.verbose.oklns 'Entry table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropEntryCommentTable = (next) ->
  db.postgres.schema.dropTableIfExists('entry_comment').then ()->
    grunt.verbose.oklns 'EntryComment table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropAnnouncementTable = (next) ->
  db.postgres.schema.dropTableIfExists('announcement').then ()->
    grunt.verbose.oklns 'Announcement table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropAnnouncementConfirmationTable = (next) ->
  db.postgres.schema.dropTableIfExists('announcement_confirmation').then ()->
    grunt.verbose.oklns 'AnnouncementConfirmation table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error