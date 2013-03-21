module.exports = class Revenue extends Striker.Collection
  schema: ['customer_id', 'period_id']

  calculate: (customerId, periodId) ->
    summaries = Striker.utils.where app.financialSummary,
      period_id:   periodId
      customer_id: customerId
      account_id:  _.pluck(app.accounts.revenue(), 'id')
    total = Striker.utils.sum(summaries, 'amount_cents')

    actual:   if total isnt 0 then total else undefined
