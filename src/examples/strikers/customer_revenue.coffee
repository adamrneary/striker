module.exports = class Revenue extends Striker.Collection
  schema: ['customer_id', 'period_id']

  indexes:
    'financialSummary': ['account_id', 'customer_id', 'period_id']

  observers:
    financialSummary: (model, changed) ->
      # see only updates for revenue accounts
      return unless _.include(_.pluck(app.accounts.revenue(), 'id'), model.get('account_id'))

      if _.has(changed, 'amount_cents')
        @update(model.get('customer_id'), model.get('period_id'))

  calculate: (customerId, periodId) ->
    accounts  = _.pluck(app.accounts.revenue(), 'id')
    summaries = Striker.query('financialSummary', customer_id: customerId, period_id: periodId, account_id: accounts)

    object = {}
    object.actual = Striker.sum(summaries, 'amount_cents') unless _.isEmpty(summaries)
    object
