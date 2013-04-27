module.exports = class Revenue extends Striker.Collection
  schema: ['customer_id', 'period_id']

  indexes:
    'financialSummary': ['period_id', 'customer_id', 'account_id']

  observers:
    financialSummary: (model, changed) ->
      # see only updates for revenue accounts
      return unless _.include(_.pluck(app.accounts.revenue(), 'id'), model.get('account_id'))

      if _.has(changed, 'amount_cents')
        @update(model.get('customer_id'), model.get('period_id'))

  calculate: (customerId, periodId) ->
    summaries = _.map _.pluck(app.accounts.revenue(), 'id'), (accountId) ->
      Striker.where('financialSummary', period_id: periodId, customer_id: customerId, account_id:  accountId)
    summaries = _.flatten(summaries)

    object = {}
    object.actual = Striker.sum(summaries, 'amount_cents') unless _.isEmpty(summaries)
    object
