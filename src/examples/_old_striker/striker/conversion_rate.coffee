module.exports = class ConversionRate extends Striker.Collection
  groupBy: ['period_id', 'stage_not_topline_id']

  default: ->
    # @conversion = app.conversion.get
    # app.periods.setAnalysis(@)

  calc: (periodId) ->
    # stages = {}
    # for stageId in app.stages.notToplineIds()
    #   prevStageId  = app.stages.nextId(stageId)
    #   stageLag     = app.stages.get(prevStageId).lag()
    #   prevPeriodId = if stageLag is 1 then app.periods.nextId(periodId) else periodId
    #
    #   result = {}
    #   if prevPeriodId
    #     conversion     = @conversion(periodId)?[stageId]
    #     prevConversion = @conversion(prevPeriodId)?[prevStageId]
    #
    #     if prevConversion && conversion
    #       result.actual = conversion.actual / prevConversion.actual if app.periods.notFuture(periodId)
    #       result.plan   = conversion.plan   / prevConversion.plan
    #   stages[stageId] = result ? null
    # stages