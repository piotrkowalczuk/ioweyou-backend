db = require '../db'

module.exports =
  getById: (id) ->
    getById(id)
  getAll: (id) ->
    getAll(id)
  getSummary: (id) ->
    getSummary(id)

getById = (id) ->

  db()
    .from('entry_entry')
    .select(
      'entry_entry.*',
      'debtor.first_name as debtor_first_name',
      'debtor.last_name as debtor_last_name',
      'debtor.username as debtor_username',
      'lender.first_name as lender_first_name',
      'lender.last_name as lender_last_name',
      'lender.username as lender_username'
    )
    .join('auth_user as debtor', 'debtor.id', '=', 'entry_entry.debtor_id', 'left')
    .join('auth_user as lender', 'lender.id', '=', 'entry_entry.lender_id', 'left')
    .where('entry_entry.id', id)
    .where('entry_entry.status', '<', '3')

getAll = (id) ->

  db()
    .from('entry_entry')
    .select(
      'entry_entry.*',
      'debtor.first_name as debtor_first_name',
      'debtor.last_name as debtor_last_name',
      'debtor.username as debtor_username',
      'lender.first_name as lender_first_name',
      'lender.last_name as lender_last_name',
      'lender.username as lender_username'
    )
    .join('auth_user as debtor', 'debtor.id', '=', 'entry_entry.debtor_id', 'left')
    .join('auth_user as lender', 'lender.id', '=', 'entry_entry.lender_id', 'left')
    .where('entry_entry.status', '<', '3')
    .where('debtor.id', id)
    .orWhere('lender.id', id)
    .orderBy('entry_entry.created_at', 'DESC')


getSummary = (id) ->

  db()
    .from('entry_entry')
    .select(
      'entry_entry.*'
    )
    .where('entry_entry.status', '<', '3')
    .where('entry_entry.debtor_id', id)
    .orWhere('entry_entry.lender_id', id)