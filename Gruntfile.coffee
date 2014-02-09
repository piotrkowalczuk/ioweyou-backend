migration = require './tasks/migration'

module.exports = (grunt) ->

  grunt.initConfig
    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coffee-script'
          mocha: require('mocha')
        src: ['test/**/*_test.coffee']


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

  grunt.registerTask 'migration:syncdb', 'Synchronizes the database schema', () ->
    done = this.async()
    migration.syncdb (message) ->
      grunt.log.writeln message
      done()

  grunt.loadNpmTasks('grunt-mocha-test');
