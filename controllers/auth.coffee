uuid = require 'node-uuid'
request = require 'request'
auth = require '../lib/auth'
facebook = require '../lib/facebook'
userTable = require '../models/user'
config = require '../config'
db = require '../db'
session = require '../models/session'

module.exports = (app) ->
  app.post '/login', login


login = (req, res) ->
  facebookToken = req.body.pass
  req.session = session

  # check if token match App id.
  request.get facebook.getGraphAPI.AppRequest(facebookToken), (error, response, appResponseBody) ->
    appResponseObject = JSON.parse(appResponseBody)
    if not error && response.statusCode == 200
      request.get facebook.getGraphAPI.MeRequest(facebookToken), (error, response, meResponseBody) ->
        meResponseObject = JSON.parse(meResponseBody)
        if not error && response.statusCode == 200
          if not (appResponseObject.id is config.facebook.appId)
            res.status(403).send('Forbiden')
          else
            userTable.getByFacebookId(meResponseObject.id).exec (error, response)->
              if not error

                userData =
                  username: response[0].username
                  first_name: response[0].first_name
                  last_name: response[0].last_name
                  email: response[0].email
                  facebookId: meResponseObject.id
                  ioweyouToken: uuid.v4()
                  ioweyouId: response[0].id.toString()

                console.log userData

                req.session.setUserData(userData.ioweyouId, userData)
                res.header "Content-Type", "application/json"
                res.send userData
              else
                res.send error

        else
          res.status(response.statusCode).send meResponseBody
    else
      res.status(response.statusCode).send appResponseBody
