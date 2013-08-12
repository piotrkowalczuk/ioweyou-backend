express = require('express')
request = require('request')
redis = require("redis")
config = require('../config')

#---- redis ----
rClient = redis.createClient();

module.exports =
  tokenAuth: (req, res, next) ->
    uid = req.query.uid
    apiToken = req.query.apiToken

    rClient.get uid, (err, reply) ->
      if reply == apiToken
        next()
      else
        res.status(403).send 'Forbiden'