module.exports = class ChurnRate extends Striker.Collection
  default: ->
    @churn          = app.churn.get
    @customerVolume = app.customerVolume.get
    app.periods.setAnalysis(@)

  calc: (periodId) ->
    result         = {}
    churn          = @churn(periodId)
    prevPeriodId   = app.periods.prevId(periodId)
    customerVolume = Striker.utils.specialCondition @customerVolume(prevPeriodId)

    result.plan = if customerVolume && churn then churn?.plan / customerVolume else null
    if app.periods.notFuture(periodId)
      result.actual = if customerVolume && churn then churn?.actual / customerVolume else null
    result
