apnagent = require 'apnagent'
join = require('path').join
pfx = join __dirname, '../certificates/IOweYOUDevelopmentPushCertificate.p12'

module.exports =
  extend: (app, config) ->
    extend(app, config)


extend = (app, config) ->
  agent = new apnagent.Agent()
  agent
    .set('pfx file', pfx)
    .set('expires', config.expiration)
    .set('reconnect delay', config.reconnectDelay)
    .set('cache ttl', config.cacheTTL)

  agent.enable('sandbox')

  agent.on 'message:error', (error, message) ->
    console.error error, message

  agent.connect (err) ->
    if err and err.name is 'GatewayAuthorizationError'
      console.log 'Authentication Error: %s', err.message
      process.exit(1)
    else if err
      throw err

    console.log "APN running on #{config.env}."

  app.use (req, res, next) ->
    res.apn = agent;
    next()

  app.apn = agent;


