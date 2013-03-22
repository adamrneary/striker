module.exports = class Revenue extends Striker.Collection
  schema: ['customer_id', 'period_id']

  observers:
    financialSummary: (model, changed) ->
      # see only updates for revenue accounts
      return unless _.include(_.pluck(app.accounts.revenue(), 'id'), model.get('account_id'))

      if _.has(changed, 'amount_cents')
        @update(model.get('customer_id'), model.get('period_id'))

  calculate: (customerId, periodId) ->
    summaries = Striker.filter 'financialSummary',
      period_id:   periodId
      customer_id: customerId
      account_id:  _.pluck(app.accounts.revenue(), 'id')

    actual: if _.isEmpty(summaries) then undefined \
            else Striker.sum(summaries, 'amount_cents')
