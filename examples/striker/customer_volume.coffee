module.exports = class CustomerVolume extends Striker.Collection
  default: ->
    @customerVolume   = @get
    @customersRevenue = app.customers.revenue
    @newCustomerCount = app.newCustomerCount?.get
    @churn            = app.churn?.get
    app.periods.setAnalysis(@)

  calc: (periodId) ->
    result = {}
    positiveCustomers = (customerId for customerId, value of @customersRevenue(periodId) when value.actual > 0).length
    result.actual = positiveCustomers if positiveCustomers > 0

    prevPeriodId = app.periods.prevId(periodId)
    prevValue    = if prevPeriodId then Striker.utils.specialCondition @customerVolume(prevPeriodId) else 0
    newCustomers = @newCustomerCount?(periodId)?.plan ? 0
    churn        = @churn(periodId)?.plan ? 0
    result.plan = prevValue + newCustomers - churn
    result
