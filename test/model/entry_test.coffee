app = require('../../app.coffee').app
expect = require('chai').expect
http = require 'http'
config = require '../../config'
clearDatabase = require '../../database/clear'
syncDatabase = require '../../database/schema'
fixturesDatabase = require '../../database/fixtures'
serverHelper = require '../helpers/server'
moment = require "moment"
entryTable = require '../../models/entry'

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
      entryTable.getById 1, (entry)->
        expect(entry).to.have.property 'id', 1
        done()

    it "should return undefined, if entry doesn't exists", (done)->
      entryTable.getById 9999, (entry)->
        expect(entry).to.be.undefined
        done()

    it "should return undefined, if entry exists but is deleted", (done)->
      entryTable.getById 3, (entry)->
        expect(entry).to.be.undefined
        done()

  describe 'getUserEntryById', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/entry_fixtures/getUserEntryById.json', (error, result)->
            done()

    it "should return entry, if user is lender", (done)->
      entryTable.getUserEntryById 1, 1, (entry)->
        expect(entry).to.have.property 'id', 1
        done()

    it "should return entry, if user is debtor", (done)->
      entryTable.getUserEntryById 1, 2, (entry)->
        expect(entry).to.have.property 'id', 2
        done()

    it "should return undefined, if entry exists but is deleted", (done)->
      entryTable.getUserEntryById 1, 3, (entry)->
        expect(entry).to.be.undefined
        done()

  describe 'getAll', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/entry_fixtures/getAll.json', (error, result)->
            done()

    it "should return 8 entries, if user is lender and there is no filters", (done)->
      entryTable.getAll 1, {}, (entries)->
        expect(entries.length).to.eql(8)
        done()

    it "should return 2 entries, if from is equal \"1999-02-02 00:00:00\"", (done)->
      filters =
        from: moment("1999-02-02 00:00:00").valueOf()

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(2)
        done()

    it "should return 1 entry, if to is equal \"1999-01-01 00:00:00\"", (done)->
      filters =
        to: moment("1999-01-01 00:00:00").valueOf()

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(1)
        done()

    it "should return 1 entry, if contractor is equal \"3\"", (done)->
      filters =
        contractor: 3

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(1)
        done()

    it "should return no entries, if status is equal \"3\"", (done)->
      filters =
        status: 3

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(0)
        done()

    it "should return 1 entry, if status is equal \"2\"", (done)->
      filters =
        status: 2

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(1)
        done()

    it "should return 8 entries, if name is equal \"entry\"", (done)->
      filters =
        name: "entry"

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(8)
        done()

    it "should return 2 entries, if name is equal \"1\"", (done)->
      filters =
        name: "1"

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(2)
        done()

    it "should return 4 entries, if limit is equal \"4\"", (done)->
      filters =
        limit: 4

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(4)
        done()

    it "should return 2 entries, if limit is equal \"4\" and offset is equal \"6\"", (done)->
      filters =
        limit: 4
        offset: 6

      entryTable.getAll 1, filters, (entries)->
        expect(entries.length).to.eql(2)
        done()

    it "should return no entries, if user does not exists", (done)->
      entryTable.getAll 4, {}, (entries)->
        expect(entries.length).to.eql(0)
        done()

  describe 'getSummary', ()->

    beforeEach (done)->
      clearDatabase.exec (error, result) ->
        syncDatabase.exec (error, result) ->
          fixturesDatabase.load '/test/model/entry_fixtures/getSummary.json', (error, result)->
            done()

    it "should return no -1.00 for user#1, if there is no filters", (done)->
      entryTable.getSummary 1, {}, (error, summary)->
        expectedValue = -1
        expect(summary).to.eql(expectedValue.toFixed(2))
        done()

    it "should return no 105.00 for user#2, if there is no filters", (done)->
      entryTable.getSummary 2, {}, (error, summary)->
        expectedValue = 105
        expect(summary).to.eql(expectedValue.toFixed(2))
        done()