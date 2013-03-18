# SalesMarketingExpense - transactions where the account is expense group == CAC
#
# Examples:
#
#   salesMarketingExpense = new SalesMarketingExpense(financialSummary, accounts)
#   # get sales marketing expense during the year
#   salesMarketingExpense.get periods.range(-2, -1)
#   # => {
#     2012-01: {actual: 25, plan: 0}
#     2012-02: {actual: 38, plan: 0}
#   }
#
#   # get sales marketing expense on 2012-02
#   salesMarketingExpense.getValue '2012-02'
#   # => {actual: 38, plan: 0}
module.exports = class SalesMarketingExpense extends Striker.Collection
  initialize: ->
    @setBackbone app.financialSummary, account_id: app.accounts.filterIds('isSalesMarketing')

  plan: ->
    app.periods.eachIds (periodId) =>
      plan = for segmentId, value of app.channels.salesMarketingExpense(periodId)
        value.plan
      @set periodId, plan: _.sum(plan)
