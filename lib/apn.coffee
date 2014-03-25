apnagent = require 'apnagent'
join = require('path').join
config = require '../config'
pfx = join __dirname, '../certificates/IOweYOUDevelopmentPushCertificate.p12'

CreateAgent = () ->
  agent = new apnagent.Agent()
  agent
    .set('pfx file', pfx)
    .set('expires', config.apn.expiration)
    .set('reconnect delay', config.apn.reconnectDelay)
    .set('cache ttl', config.apn.cacheTTL)

  agent.enable('sandbox')

  agent.on 'message:error', (error, message) ->
    console.error error, message

  agent.connect (err) ->
    if err and err.name is 'GatewayAuthorizationError'
      console.log 'Authentication Error: %s', err.message
      process.exit(1)
    else if err
      throw err

    console.log "APN running on #{config.apn.env}."

  return agent

apn = exports.apn = CreateAgent()