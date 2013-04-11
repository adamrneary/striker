module.exports = class NewCustomers extends Striker.Collection
  default: ->
    @customers = -> app.customers.models
    app.periods.setAnalysis(@)

  calc: (periodId) ->
    result       = []
    prevPeriodId = app.periods.prevId(periodId)
    prevRevenue  = app.customers.revenue(prevPeriodId)
    revenue      = app.customers.revenue(periodId)

    if revenue
      for customerId in _.pluck(@customers(), 'id')
        if _.isUndefined(prevPeriodId)
          result.push(customerId) if revenue[customerId].actual > 0
        else if prevRevenue && prevRevenue[customerId].actual <= 0 and revenue[customerId].actual > 0
          result.push(customerId)
    result
