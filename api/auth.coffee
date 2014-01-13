uuid = require 'node-uuid'
request = require 'request'
auth = require '../lib/auth'
facebook = require '../lib/facebook'
userTable = require '../models/user'
config = require '../config'
db = require '../db'
session = require '../models/session'

module.exports = (app) ->
  app.post '/api/login', login
  app.post '/api/register', register


login = (req, res) ->
  ###
    check if token match App id.
  ###
  facebookToken = req.body.pass
  req.session = session

  request.get facebook.getGraphAPI.AppRequest(facebookToken), (error, response, appResponseBody) ->
    appResponseObject = JSON.parse(appResponseBody)
    if not error and response.statusCode == 200
      request.get facebook.getGraphAPI.MeRequest(facebookToken), (error, response, meResponseBody) ->
        meResponseObject = JSON.parse(meResponseBody)
        if not error and response.statusCode == 200
          if appResponseObject.id isnt config.facebook.appId
            res.status(403).send('Forbidden')
          else
            userTable.getByFacebookId meResponseObject.id, (user)->
              if user

                userData =
                  username: user.username
                  first_name: user.first_name
                  last_name: user.last_name
                  email: user.email
                  facebookId: meResponseObject.id
                  ioweyouToken: uuid.v4()
                  ioweyouId: user.id.toString()

                req.session.setUserData userData.ioweyouId, userData
                res.header "Content-Type", "application/json"
                res.status 200
                res.send userData
              else
                res.send false

        else
          res.status(response.statusCode).send meResponseBody
    else
      res.status(response.statusCode).send appResponseBody


register = (req, res) ->

  facebookToken = req.body.token

  userTable.getByFacebookId facebookToken, (user)->

    if not user
      request.get facebook.getGraphAPI.AppRequest(facebookToken), (error, response, appResponseBody) ->
        appResponseObject = JSON.parse(appResponseBody)
        if not error && response.statusCode == 200
          request.get facebook.getGraphAPI.MeRequest(facebookToken), (error, response, meResponseBody) ->
            meResponseObject = JSON.parse(meResponseBody)
            if not error && response.statusCode == 200
              if not (appResponseObject.id is config.facebook.appId)
                res.status(403).send('Forbidden')
              else