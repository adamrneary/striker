# Calculate overall conversion
# Show conversionSummary and conversionForecast grouped by stage and period
# Use summary for "actual" data and forecast for "plan" data
#
# Examples:
#
#   conversion = new Conversion()
#   conversion.get periods.range(-3, 2)
#   # => {
#     2012-01: {stage1: {actual: 20, plan: 0},  stage2: {actual: 20, plan: 0}}
#     2012-02: {stage1: {actual: 7,  plan: 0},  stage2: {actual: 10, plan: 0}}
#     2012-03: {stage1: {actual: 2,  plan: 0},  stage2: {actual: 30, plan: 28}}
#     2012-04: {stage1: {actual: 8,  plan: 20}, stage2: {actual: 9,  plan: 8}}
#     2012-05: {stage1: {plan: 7},  stage2: {plan: 16}}
#     2012-06: {stage1: {plan: 2},  stage2: {plan: 26}}
#   }
module.exports = class Conversion extends Striker.Collection
  groupBy: ['period_id', 'stage_id']

  initialize: ->
    @setBackbone app.conversionSummary, stage_id: app.stages.notCustomerIds()
    @setBackbone app.conversionForecast

  actual: ->
    customerStageId = app.stages.customer().id
    items = for periodId in app.periods.range(null, 0)
      count = app.newCustomers?.get(periodId)?.length ? 0
      period_id: periodId, stage_id: customerStageId, count: count

    @assign items, getValue: (item) -> actual: item.count
