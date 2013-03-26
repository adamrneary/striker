observer = (value) ->
  (model, changed) ->
    if _.has(changed, value)  
      @update(
        app.periods.findWhere(first_day: model.get('balance_as_of')).get('id')
      )

module.exports = class CashOnHand extends Striker.Collection
  schema: ['period_id']

  observers:
    accounts:  observer('current_balance')

  calculate: (periodId) ->
    balance_as_of      = app.periods.idToDate(periodId)
    accounts           = Striker.where('accounts',  {activecell_category: 'cash', balance_as_of: balance_as_of})

    result = {}
    result.actual   = Striker.sum(accounts, 'current_balance')
    result
