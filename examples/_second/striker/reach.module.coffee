OldStriker = require('striker/base/striker')

# Calculate reach
# Filtered conversionSummary and conversionForecast by stage, group by period and channel
# Use summary for 'actual' data and forecast for 'plan' data
#
# Examples:
#
#   reach = new Reach()
#   reach.get ['2012-01', '2012-02', '2012-03', '2012-04', '2012-05', '2012-06']
#   # => {
#     2012-01: {channel1: {actual: 20, plan: 8},  channel2: {actual: 20, plan: 18}}
#     2012-02: {channel1: {actual: 7,  plan: 8},  channel2: {actual: 10, plan: 18}}
#     2012-03: {channel1: {actual: 2,  plan: 0},  channel2: {actual: 30, plan: 28}}
#     2012-04: {channel1: {actual: 23, plan: 20}, channel2: {actual: 8,  plan: 8}}
#     2012-05: {channel1: {plan: 7},  channel2: {plan: 16}}
#     2012-06: {channel1: {plan: 2},  channel2: {plan: 26}}
#   }
module.exports = class Reach extends OldStriker
  groupBy: ['period_id', 'channel_id']

  initialize: ->
    toplineStageId = app.stages.topline()?.id

    @setBackbone app.conversionSummary,  stage_id: toplineStageId
    @setBackbone app.conversionForecast, stage_id: toplineStageId
