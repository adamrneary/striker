Collection = require('lib/collection')

module.exports = class FinancialSummary extends Collection
  url: 'api/v1/financial_summary'

  getValue: ->
    (item) -> actual: item.amount_cents

  #############################################################################
  # filter methods
  #############################################################################

  inRange: (period_ids) ->
    @wrappedWhere (model) ->
      _.include period_ids, model.get('period_id')

  revenue: ->
    @wrappedWhere (model) ->
      _.include app.accounts.revenue().ids(), model.get('account_id')

  cogs: ->
    @wrappedWhere (model) ->
      _.include app.accounts.cogs().ids(), model.get('account_id')

  expense: ->
    @wrappedWhere (model) ->
      _.include app.accounts.expense().ids(), model.get('account_id')

  #############################################################################
  # aggregation methods
  #############################################################################

  totalAmount: ->
    @reduce ((memo, model) ->
        memo + model.get('amount_cents')
      ), 0