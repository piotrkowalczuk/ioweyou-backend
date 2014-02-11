db = require '../db'
async = require 'async'
grunt = require 'grunt'

module.exports =
  exec: (next) ->
    exec(next)

exec = (next) ->
    operations = [
      createMigrationTable,
      createUserTable,
      createUserClientTable,
      createUserFriendshipTable,
      createUserSocialTable,
      createEntryTable,
      createEntryCommentTable,
      createAnnouncementTable,
      createAnnouncementConfirmationTable
    ]

    async.series operations, (error, result) ->
      if error
        grunt.verbose.errorlns "#{result.length - 1} tables created successfuly"
      else
        grunt.verbose.oklns "#{result.length} tables created successfuly"

      next(error, result)


createMigrationTable = (next) ->
  db.postgres.schema.createTable 'migration', (table)->
    table.bigIncrements('id')
    table.integer('version')
    table.timestamps()
  .then () ->
    grunt.verbose.oklns 'Migration table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'Migration table was not created, error occurred.'
    next(error)


createUserTable = (next) ->
  db.postgres.schema.createTable 'user', (table)->
    table.bigIncrements('id')
    table.string('password', 128).notNullable()
    table.string('username', 30).notNullable().unique().index()
    table.string('first_name', 30).notNullable()
    table.string('last_name', 30).notNullable()
    table.string('email', 75).notNullable().index()
    table.boolean('is_active').defaultTo(true)
    table.timestamps()
  .then () ->
    grunt.verbose.oklns 'User table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'User table was not created, error occurred.'
    next(error)


createUserClientTable = (next) ->
  db.postgres.schema.createTable 'user_client', (table)->
    table.bigIncrements('id')
    table.string('name', 255).notNullable()
    table.string('token', 255)
    table.integer('user_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('user')
      .onDelete("CASCADE")
    table.timestamps()
  .then ()->
    grunt.verbose.oklns 'UserClient table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'UserClient table was not created, error occurred.'
    next(error)


createUserFriendshipTable = (next) ->
  db.postgres.schema.createTable 'user_friendship', (table)->
    table.bigIncrements('id')
    table.integer('creator_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('user')
      .onDelete("CASCADE")
    table.integer('friend_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('user')
      .onDelete("CASCADE")
    table.timestamp('created_at')
  .then ()->
    grunt.verbose.oklns 'UserFriendship table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'UserFriendship table was not created, error occurred.'
    next(error)


createUserSocialTable = (next) ->
  db.postgres.schema.createTable 'user_social', (table)->
    table.bigIncrements('id')
    table.integer('user_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('user')
      .onDelete("CASCADE")
    table.string('provider', 64).notNullable()
    table.string('uid', 255).notNullable()
    table.text('extra_data').notNullable()
  .then ()->
    grunt.verbose.oklns 'UserSocial table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'UserSocial table was not created, error occurred.'
    next(error)


createEntryTable = (next) ->
  db.postgres.schema.createTable 'entry', (table)->
    table.bigIncrements('id')
    table.string('name', 255).notNullable()
    table.text('description')
    table.float('value', 6, 2)
    table.tinyInteger('status')
    table.integer('debtor_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('user')
      .onDelete("SET NULL")
    table.integer('lender_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('user')
      .onDelete("SET NULL")
    table.timestamp('accepted_at')
    table.timestamp('rejected_at')
    table.timestamp('deleted_at')
    table.timestamps()
  .then ()->
    grunt.verbose.oklns 'Entry table created successfully'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'Entry table was not created, error occurred.'
    next(error)


createEntryCommentTable = (next) ->
  db.postgres.schema.createTable 'entry_comment', (table)->
    table.bigIncrements('id')
    table.text('content')
    table.integer('user_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('user')
      .onDelete("SET NULL")
    table.integer('entry_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('entry')
      .onDelete("CASCADE")
    table.timestamps()
  .then ()->
    grunt.verbose.oklns 'EntryComment table created successfully'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'EntryComment table was not created, error occurred.'
    next(error)


createAnnouncementTable = (next) ->
  db.postgres.schema.createTable 'announcement', (table)->
    table.bigIncrements('id')
    table.string('title', 255).notNullable()
    table.text('content').notNullable()
    table.timestamps()
  .then ()->
    grunt.verbose.oklns 'Announcement table created successfully'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'Announcement table was not created, error occurred.'
    next(error)

createAnnouncementConfirmationTable = (next) ->
  db.postgres.schema.createTable 'announcement_confirmation', (table)->
    table.bigIncrements('id')
    table.integer('announcement_id')
      .notNullable()
      .unsigned()
      .references('id')
      .inTable('announcement')
      .onDelete("CASCADE")
    table.timestamp('created_at')
  .then ()->
    grunt.verbose.oklns 'AnnouncementConfirmation table created successfully'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'AnnouncementConfirmation table was not created, error occurred.'
    next(error)

