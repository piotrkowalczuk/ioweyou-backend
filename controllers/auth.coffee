uuid = require 'node-uuid'
request = require 'request'
auth = require '../lib/auth'
facebook = require '../lib/facebook'
userTable = require '../models/user'
config = require '../config'
db = require '../db'

module.exports = (app) ->
  app.post '/login', login


login = (req, res) ->
  facebookToken = req.body.access_token

  # check if token match App id.
  request.get facebook.getGraphAPI.AppRequest(facebookToken), (error, response, appResponseBody) ->
    appResponseObject = JSON.parse(appResponseBody)
    if not error && response.statusCode == 200
      request.get facebook.getGraphAPI.MeRequest(facebookToken), (error, response, meResponseBody) ->
        meResponseObject = JSON.parse(meResponseBody)
        if not error && response.statusCode == 200
          console.log meResponseObject
          if not (appResponseObject.id is config.facebook.appId)
            res.status(403).send('Forbiden')

          userTable.getByFacebookId(meResponseObject.id).exec (error, response)->

            if not error

              userData =
                id: response[0].id
                username: response[0].username
                first_name: response[0].first_name
                last_name: response[0].last_name
                email: response[0].email
                uid: meResponseObject.id
                apiToken: uuid.v4()

              req.session.setUserData(meResponseObject.id, userData)
              res.send userData
            else
              res.send error

        else
          res.status(response.statusCode).send meResponseBody
    else
      res.status(response.statusCode).send appResponseBody
