module.exports =
  usersToArrayOfIds: (users) ->
    usersToArrayOfIds(users)


usersToArrayOfIds = (users) ->
  tmpArray = []
  for user in users
    tmpArray.push(user.id)

  return tmpArray
