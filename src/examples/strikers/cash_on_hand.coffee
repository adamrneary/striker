module.exports = class CashOnHand extends Striker.Collection
  schema: ['period_id']

  indexes:
    'accounts': ['activecell_category', 'balance_as_of']

  observers:
    accounts: (model, changed) ->
      if _.has(changed, 'current_balance')
        @update(app.periods.findWhere(first_day: model.get('balance_as_of')).get('id'))

  calculate: (periodId) ->
    balanceAsOf = app.periods.idToDate(periodId)
    accounts    = Striker.where('accounts', activecell_category: 'cash', balance_as_of: balanceAsOf)

    result = {}
    result.actual   = Striker.sum(accounts, 'current_balance')
    result
