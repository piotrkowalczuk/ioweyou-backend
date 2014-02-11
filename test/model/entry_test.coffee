app = require('../../app.coffee').app
expect = require('chai').expect
http = require 'http'
config = require '../../config'
clearDatabase = require '../../database/clear'
syncDatabase = require '../../database/schema'
fixturesDatabase = require '../../database/fixtures'
serverHelper = require '../helpers/server'
moment = require "moment"

server = null

describe 'model/entry', ()->
  before (done)->
    server = serverHelper.createServer done

  after (done)->
    server.close()
    done()

  describe 'getById', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/entry_fixtures/getById.json', (error, result)->
            done()

    it "should return entry, if entry exists", (done)->
      require('../../models/entry').getById 1, (entry)->
        expect(entry).to.have.property 'id', 1
        done()

    it "should return undefined, if entry doesn't exists", (done)->
      require('../../models/entry').getById 9999, (entry)->
        expect(entry).to.be.undefined
        done()

    it "should return undefined, if entry exists but is deleted", (done)->
      require('../../models/entry').getById 3, (entry)->
        expect(entry).to.be.undefined
        done()

  describe 'getUserEntryById', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/entry_fixtures/getUserEntryById.json', (error, result)->
            done()

    it "should return entry, if user is lender", (done)->
      require('../../models/entry').getUserEntryById 1, 1, (entry)->
        expect(entry).to.have.property 'id', 1
        done()

    it "should return entry, if user is debtor", (done)->
      require('../../models/entry').getUserEntryById 1, 2, (entry)->
        expect(entry).to.have.property 'id', 2
        done()

    it "should return undefined, if entry exists but is deleted", (done)->
      require('../../models/entry').getUserEntryById 1, 3, (entry)->
        expect(entry).to.be.undefined
        done()

  describe 'getAll', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/entry_fixtures/getAll.json', (error, result)->
            done()

    it "should return 8 entries, if user is lender and there is no filters", (done)->
      require('../../models/entry').getAll 1, {}, (entries)->
        expect(entries.length).to.eql(8);
        done()

    it "should return 2 entries, if from is equal \"1999-02-02 00:00:00\"", (done)->
      filters =
        from: moment("1999-02-02 00:00:00").valueOf()

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(2);
        done()

    it "should return 1 entry, if to is equal \"1999-01-01 00:00:00\"", (done)->
      filters =
        to: moment("1999-01-01 00:00:00").valueOf()

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(1);
        done()

    it "should return 1 entry, if contractor is equal \"3\"", (done)->
      filters =
        contractor: 3

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(1);
        done()

    it "should return no entries, if status is equal \"3\"", (done)->
      filters =
        status: 3

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(0);
        done()

    it "should return 1 entry, if status is equal \"2\"", (done)->
      filters =
        status: 2

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(1);
        done()

    it "should return 8 entries, if name is equal \"entry\"", (done)->
      filters =
        name: "entry"

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(8);
        done()

    it "should return 2 entries, if name is equal \"1\"", (done)->
      filters =
        name: "1"

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(2);
        done()

    it "should return 4 entries, if limit is equal \"4\"", (done)->
      filters =
        limit: 4

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(4);
        done()

    it "should return 2 entries, if limit is equal \"4\" and offset is equal \"6\"", (done)->
      filters =
        limit: 4
        offset: 6

      require('../../models/entry').getAll 1, filters, (entries)->
        expect(entries.length).to.eql(2);
        done()

    it "should return no entries, if user does not exists", (done)->
      require('../../models/entry').getAll 4, {}, (entries)->
        expect(entries.length).to.eql(0);
        done()