userModel = require '../../models/user'
specUtils = require '../specUtils'

objectsAU = [
  {
    password:"test1"
    last_login:"2013-07-05 15:51:55.100959+02"
    is_superuser:"FALSE"
    username:"user1"
    first_name:"foo1"
    last_name:"bar1"
    email:"foo1@bar.pl"
    is_staff:"FALSE"
    is_active:"TRUE"
    date_joined:"2013-02-19 22:59:19+01"
  },
  {
    password:"test2"
    last_login:"2013-07-05 15:51:55.100959+02"
    is_superuser:"FALSE"
    username:"user2"
    first_name:"foo2"
    last_name:"bar2"
    email:"foo2@bar.pl"
    is_staff:"FALSE"
    is_active:"TRUE"
    date_joined:"2013-02-19 22:59:19+01"
  },
  {
    password:"test3"
    last_login:"2013-07-05 15:51:55.100959+02"
    is_superuser:"FALSE"
    username:"user3"
    first_name:"foo3"
    last_name:"bar3"
    email:"foo3@bar.pl"
    is_staff:"FALSE"
    is_active:"TRUE"
    date_joined:"2013-02-19 22:59:19+01"
  },
  {
    password:"test4"
    last_login:"2013-07-05 15:51:55.100959+02"
    is_superuser:"FALSE"
    username:"user4"
    first_name:"foo4"
    last_name:"bar4"
    email:"foo4@bar.pl"
    is_staff:"FALSE"
    is_active:"TRUE"
    date_joined:"2013-02-19 22:59:19+01"
  },
  {
    password:"test5"
    last_login:"2013-07-05 15:51:55.100959+02"
    is_superuser:"FALSE"
    username:"user5"
    first_name:"foo5"
    last_name:"bar5"
    email:"foo5@bar.pl"
    is_staff:"FALSE"
    is_active:"TRUE"
    date_joined:"2013-02-19 22:59:19+01"
  }
]

objectsSAU = [
  {
    user_id:"1"
    provider:"facebook"
    uid:"1"
    extra_data:''
  },
  {
    user_id:"2"
    provider:"facebook"
    uid:"2"
    extra_data:''
  },
  {
    user_id:"3"
    provider:"facebook"
    uid:"3"
    extra_data:''
  }
  {
    user_id:"4"
    provider:"facebook"
    uid:"4"
    extra_data:''
  }
  {
    user_id:"5"
    provider:"facebook"
    uid:"5"
    extra_data:''
  }
]

objectsUF = [
  {
    creator_id:"1"
    friend_id:"2"
    created_at:"2013-02-19 22:59:25+01"
  },
  {
    creator_id:"1"
    friend_id:"3"
    created_at:"2013-02-19 22:59:25+01"
  },
  {
    creator_id:"2"
    friend_id:"4"
    created_at:"2013-02-19 22:59:25+01"
  }
]

createAUTable = (next)->
  columnCreationFunction = (table)->
    table.increments 'id'
    table.string 'password'
    table.timestamp 'last_login'
    table.boolean 'is_superuser'
    table.string('username').unique()
    table.string 'first_name'
    table.string 'last_name'
    table.string 'email'
    table.boolean 'is_staff'
    table.boolean 'is_active'
    table.timestamp 'date_joined'

  specUtils.createTable('auth_user',columnCreationFunction,next)

createSAUTable = (next)->
  columnCreationFunction = (table)->
    table.increments 'id'
    table.integer('user_id').references('id').inTable 'auth_user'
    table.string 'provider'
    table.string 'uid'
    table.unique(['provider','uid'])
    table.text 'extra_data'

  specUtils.createTable('social_auth_usersocialauth',columnCreationFunction,next)

createUFTable = (next)->
  columnCreationFunction = (table)->
    table.increments 'id'
    table.integer('creator_id').references('id').inTable 'auth_user'
    table.integer('friend_id').references('id').inTable 'auth_user'
    table.timestamp 'created_at'

  specUtils.createTable('user_friendship',columnCreationFunction,next)

insertAUData = (next)->
  specUtils.insertData('auth_user',objectsAU,'id',next)

insertSAUData = (next)->
  specUtils.insertData('social_auth_usersocialauth',objectsSAU,'id',next)

insertUFData = (next)->
  specUtils.insertData('user_friendship',objectsUF,'id',next)

dropUFTable = (next)->
  specUtils.dropTable('user_friendship',next)

dropSAUTable = (next)->
  specUtils.dropTable('social_auth_usersocialauth',next)

dropAUTable = (next)->
  specUtils.dropTable('auth_user',next)

createUserTables = (next)->
  createAUTable ->
    createSAUTable ->
      createUFTable ->
        next() if next?

insertUserData = (next)->
  insertAUData ->
   insertSAUData ->
    insertUFData ->
      next() if next?

dropUserTables = (next)->
  dropUFTable ->
    dropSAUTable ->
      dropAUTable ->
        next() if next?

setUp = (next)->
  createUserTables ->
    insertUserData ->
      next() if next?

tearDown = (next)->
  dropUserTables ->
    next() if next?

#A little dirty hack for setting up before tests
describe 'setUp', ->
  it 'sets up', (done)->
    setUp ->
      done()

describe 'user.getById',->
  it 'should retrieve an user with given id', (done)->
    userModel.getById(2).exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 1
      user = results[0]
      expect(user.username).toEqual "user2"
      expect(user.first_name).toEqual "foo2"
      expect(user.last_name).toEqual "bar2"
      expect(user.email).toEqual "foo2@bar.pl"
      expect(user.uid).toEqual "2"
      done()

  it 'should retrieve no user for incorrect id', (done)->
    userModel.getById(6).exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 0
      done()

  it 'should contain an error for non-numeric id', (done)->
    userModel.getById('badId').exec (error,results)->
      expect(error).not.toBeNull()
      done()

describe 'user.getBy',->
  it 'should retrieve user list based on any column (single result case)', (done)->
    userModel.getBy('email','foo3@bar.pl').exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 1
      user = results[0]
      expect(user.username).toEqual "user3"
      expect(user.first_name).toEqual "foo3"
      expect(user.last_name).toEqual "bar3"
      expect(user.email).toEqual "foo3@bar.pl"
      expect(user.uid).toEqual "3"
      done()

  it 'should retrieve user list based on any column (many resuls case)', (done)->
    userModel.getBy('date_joined','2013-02-19 22:59:19+01').exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 5
      done()

  it 'should retrieve no users for column/value combination that matches none', (done)->
    userModel.getBy('date_joined','2013-02-19 22:59:20+01').exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 0
      done()

  it 'should contain an error for non-existent column', (done)->
    userModel.getBy('surname','bar1').exec (error,results)->
      expect(error).not.toBeNull()
      done()

  it 'should contain an error for incorrect value for given column', (done)->
    userModel.getBy('is_staff',5).exec (error,results)->
      expect(error).not.toBeNull()
      done()

describe 'user.getFriends',->
  it 'should get friend list for an user with given id', (done)->
    userModel.getFriends(1).exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 2
      done()

describe 'user.getFriends',->
  it 'should get friend list for an user with given id', (done)->
    userModel.getFriends(1).exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 2
      done()

  it "should get a list that contains first user's id in seconds user's list when first user's list contains
      second user's id", (done)->
    userModel.getFriends(1).exec (error,results)->
      expect(error).toBeNull()
      firstList = results
      firstListIds = (friend.uid for friend in firstList)
      userModel.getFriends(2).exec (error,results)->
        expect(error).toBeNull()
        secondList = results
        secondListIds = (friend.uid for friend in secondList)
        expect(secondListIds).toContain '1'
        expect(firstListIds).toContain '2'
        done()

  it "should get an empty friend list for a user with no friends", (done)->
    userModel.getFriends(5).exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 0
      done()

  it "should get an empty friend list for non-existent user", (done)->
    userModel.getFriends(6).exec (error,results)->
      expect(error).toBeNull()
      expect(results.length).toEqual 0
      done()

  it "should contain an error for non-numeric id", (done)->
    userModel.getFriends('badId').exec (error,results)->
      expect(error).not.toBeNull()
      done()

#A little dirty hack for tearing down after tests
describe 'tearDown', ->
  it 'tears down', (done)->
    tearDown ->
      done()