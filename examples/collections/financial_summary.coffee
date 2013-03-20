HFCollection = require('lib/hf_collection')

module.exports = class FinancialSummary extends HFCollection
  url: 'api/v1/financial_summary'

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