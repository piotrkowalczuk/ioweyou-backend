db = require '../db'

module.exports =
  exec: () ->
    exec()


exec = () ->

  db.postgres.schema.createTable 'migration', (table)->
    table.bigIncrements('id')
    table.integer('version')
    table.timestamps()
  .then ()->
      console.log 'Migration table created successfully.'

  db.postgres.schema.createTable 'user', (table)->
    table.bigIncrements('id')
    table.string('password', 128).notNullable()
    table.string('username', 30).notNullable().unique().index()
    table.string('first_name', 30).notNullable()
    table.string('last_name', 30).notNullable()
    table.string('email', 75).notNullable().index()
    table.boolean('is_active').defaultTo(true)
    table.timestamps()
  .then ()->
      console.log 'User table created successfully.'

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
      console.log 'UserClient table created successfully.'

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
      console.log 'UserFriendship table created successfully.'

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
      console.log 'UserSocial table created successfully.'

  db.postgres.schema.createTable 'entry', (table)->
    table.bigIncrements('id')
    table.text('name')
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
      console.log 'Entry table created successfully'

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
      console.log 'EntryComment table created successfully'

  db.postgres.schema.createTable 'announcement', (table)->
    table.bigIncrements('id')
    table.string('title', 255).notNullable()
    table.text('content').notNullable()
    table.timestamps()
  .then ()->
      console.log 'Announcement table created successfully'

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
      console.log 'AnnouncementConfirmation table created successfully'

  console.log 'Schema synced.'
  process.exit()

exec()