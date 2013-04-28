module.exports = class Revenue extends Striker.Collection
  schema: ['customer_id', 'period_id']

  indexes:
    'financialSummary': ['period_id', 'account_id', 'customer_id']

  observers:
    financialSummary: (model, changed) ->
      return unless _.include(@cache('revenue'), model.get('account_id'))

      if _.has(changed, 'amount_cents')
        @update(model.get('customer_id'), model.get('period_id'))

  calculate: (customerId, periodId) ->
    accounts  = @cache('revenue')
    summaries = Striker.query('financialSummary', customer_id: customerId, period_id: periodId, account_id: accounts)

    object = {}
    object.actual = Striker.sum(summaries, 'amount_cents') unless _.isEmpty(summaries)
    object
