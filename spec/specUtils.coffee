db = require '../db'
#Needed for Schema object methods (you can't access Schema from knex instance, only from the module itself for some reason)
knex = require 'knex'

module.exports = 
  createTable: (name,columnCreationFunction,next)->
    createTable(name,columnCreationFunction,next)
  insertData: (tableName,objectsList,returning,next)->
    insertData(tableName,objectsList,returning,next)
  dropTable: (name,next)->
    dropTable(name,next)

createTable = (name,columnCreationFunction,next)->
  knex.Schema.dropTableIfExists(name).exec (err,response)->
    knex.Schema.createTable(name, columnCreationFunction).exec (err,response)->
      next() if next?

insertData = (tableName,objectsList,returning,next)->
  db(tableName).insert(objectsList,returning).exec (err,response)->
    next() if next?

dropTable = (name,next)->
  knex.Schema.dropTableIfExists(name).exec (err,response)->
    next() if next?
