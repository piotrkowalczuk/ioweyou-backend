db = require '../../db'
Q = require 'q'


module.exports =
  version: 1
  description: "Initial migration, remove old unused tables. New naming convention."
  exec: () ->
    exec()


exec = () ->

  done = Q () ->

  done.then () ->
    db.postgres.schema.hasTable('auth_user').then (exists)->
      if exists
        db.postgres.schema.renameTable('auth_user', 'user').then ()->
          console.log ' Table auth_user renamed to user successfully.'
  .then () ->
    db.postgres.schema.hasTable('auth_user').then (exists)->
      if exists
        db.postgres.schema.renameTable('entry_entry', 'entry').then ()->
          console.log ' Table entry_entry renamed to entry successfully.'
  .then () ->
    db.postgres.schema.hasTable('announcement_announcement').then (exists)->
      if exists
        db.postgres.schema.renameTable('announcement_announcement', 'announcement').then ()->
          console.log ' Table announcement_announcement renamed to announcemen.'
  .then () ->
    db.postgres.schema.hasTable('social_auth_usersocialauth').then (exists)->
      if exists
        db.postgres.schema.renameTable('social_auth_usersocialauth', 'user_social').then ()->
          console.log ' Table social_auth_usersocialauth renamed to user_social.'
  .then () ->
    db.postgres.schema.hasTable('announcement_announcementconfirmation').then (exists)->
      if exists
        db.postgres.schema.renameTable('announcement_announcementconfirmation', 'announcement_confirmation').then ()->
          console.log ' Table announcement_announcementconfirmation renamed to announcement_confirmation successfully.'
  .then () ->
    db.postgres.schema.hasTable('entry_entrycomment').then (exists)->
      if exists
        db.postgres.schema.renameTable('entry_entrycomment', 'entry_comment').then ()->
          console.log ' Table entry_entrycomment renamed to entry_comment successfully.'
  .then () ->
    db.postgres.schema.hasTable('user_userclient').then (exists)->
      if exists
        db.postgres.schema.renameTable('user_userclient', 'user_client').then ()->
          console.log ' Table user_userclient renamed to user_client successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('auth_group').then ()->
      console.log ' Table auth_group droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('auth_group_permissions').then ()->
      console.log ' Table auth_group_permissions droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('auth_permission')
  .then ()->
    console.log ' Table auth_permission droped successfully.'
  .then ()->
    db.postgres.schema.dropTableIfExists('auth_user_groups').then ()->
      console.log ' Table auth_user_groups droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('auth_user_user_permissions').then ()->
      console.log ' Table auth_user_user_permissions droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('django_admin_log').then ()->
      console.log ' Table django_admin_log droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('django_content_type').then ()->
      console.log ' Table django_content_type droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('django_session').then ()->
      console.log ' Table django_session droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('django_site').then ()->
      console.log ' Table django_site droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('social_auth_association')
  .then ()->
      console.log ' Table social_auth_association droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('social_auth_nonce').then ()->
      console.log ' Table social_auth_nonce droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('south_migrationhistory').then ()->
      console.log ' Table south_migrationhistory droped successfully.'
  .then () ->
    db.postgres.schema.dropTableIfExists('user_userprofile').then ()->
      console.log ' Table user_userprofile droped successfully.'

  return done