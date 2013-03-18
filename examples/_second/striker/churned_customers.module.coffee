OldStriker = require('striker/base/striker')

module.exports = class ChurnedCustomers extends OldStriker
  default: ->
    @customers = -> app.customers.models
    app.periods.setAnalysis(@)

  calc: (periodId) ->
    result       = []
    prevPeriodId = app.periods.prevId(periodId)
    prevRevenue  = app.customers.revenue(prevPeriodId)
    revenue      = app.customers.revenue(periodId)

    if prevRevenue && revenue
      for customerId in _.pluck(@customers(), 'id')
        if prevRevenue[customerId].actual > 0 and revenue[customerId].actual is 0
          result.push(customerId)
    result
