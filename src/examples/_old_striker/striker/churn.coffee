module.exports = class Churn extends Striker.Collection
  default: ->
    @churnedCustomers = app.churnedCustomers?.get
    app.periods.eachIds (periodId) =>
      segmentsSum = Striker.utils.sum(values.plan for segmentId, values of app.segments.churn(periodId))
      @set periodId, @calc(periodId)
      @set periodId, plan: segmentsSum

  calc: (periodId) ->
    if churnedCustomers = @churnedCustomers?(periodId)
    then actual: churnedCustomers.length else {}
