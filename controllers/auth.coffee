pg = require('pg')
redis = require("redis")
uuid = require('node-uuid');
request = require('request')

config = require('../config')
auth = require('../lib/auth')
facebook = require('../lib/facebook')
user = require('../models/user')


#---- postgres ----
pgClient = new pg.Client(config.database.conString)
pgClient.connect()

#---- redis ----
rClient = redis.createClient();


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

          if not (appResponseObject.id is config.facebook.appId)
            res.status(403).send('Forbiden')

          user.getBy 'sau.uid', meResponseObject.id, (data) ->
            response =
              userData: data
              apiToken: uuid.v4()

            rClient.set meResponseObject.id, response.apiToken, redis.print
            res.send JSON.stringify response

        else
          res.status(response.statusCode).send meResponseBody
    else
      res.status(response.statusCode).send appResponseBody
