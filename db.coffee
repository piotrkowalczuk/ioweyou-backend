knex = require 'knex'
config = require './config'
redis = require 'redis'

module.exports = knex.Initialize(config.database)