migration = require './tasks/migration'

module.exports = (grunt) ->
  grunt.registerTask 'migration:init', 'Initialize migration system.', ()->
    done = this.async()
    migration.initialize (message) ->
      grunt.log.writeln message
      done()

  grunt.registerTask 'migration:migrate', 'Migrate database schema to current version', () ->
    done = this.async()
    migration.migrate (message) ->
      grunt.log.writeln message
      done()
