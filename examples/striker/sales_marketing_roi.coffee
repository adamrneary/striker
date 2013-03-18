# Calculate: Sales & Marketing ROI
# salesMarketingRoi = (revenue - salesMarketingExpense) / salesMarketingExpense
module.exports = class SalesMarketingRoi extends Striker.Collection
  initialize: ->
    getROI = (periodId, type) ->
      periodRevenue = app.revenue.get(periodId)[type]
      periodSME     = app.salesMarketingExpense.get(periodId)[type]
      if periodSME is 0 then 0 else (periodRevenue - periodSME) / periodSME

    app.periods.eachIds (periodId) =>
      @set periodId, actual: getROI(periodId, 'actual'), plan: getROI(periodId, 'plan')
