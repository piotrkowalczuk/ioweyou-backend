db = require '../../db'

db.postgres.schema.createTable 'migration', (table)->
  table.increments 'id'
  table.integer 'version'
  table.timestamps()
.then ()->
    console.log('Migration table is created.')