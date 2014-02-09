express = require('express')
request = require('request')

module.exports =
  getGraphAPI:
    AppRequest: (accessToken) ->
      return "https://graph.facebook.com/app?access_token=#{accessToken}"
    MeRequest: (accessToken) ->
      return "https://graph.facebook.com/me?access_token=#{accessToken}"
    FriendsRequest: (accessToken, userId) ->
      return "https://graph.facebook.com/#{userId}/friends?fields=installed,name,id&uid&limit=9999&access_token=#{accessToken}"
