OldStriker = require('striker/base/striker')
utils        = require('striker/base/utils')

# Revenue - transactions where account type is Revenue
#
# Examples:
#
#   revenue = new Revenue()
#   revenue.get ['2012-01', '2012-02', '2012-03']
#   # => {
#     2012-01: {actual: 20, plan: 0}
#     2012-02: {actual: 30, plan: 0}
#     2012-03: {actual: 12, plan: 0}
#   }
#
#   revenue.get '2012-03'
#   # => {actual: 12, plan: 0}
module.exports = class Revenue extends OldStriker
  initialize: (options) ->
    @setBackbone app.financialSummary, {account_id: app.accounts.filterIds('isRevenue')}, options.actualMap

  plan: ->
    app.periods.eachIds (periodId) =>
      plan = for segmentId, value of app.segments.revenue(periodId)
        value.plan
      @set periodId, plan: _.sum(plan)
