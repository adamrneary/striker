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
module.exports = class Reach extends Striker.Collection
  name: "Reach"

  schema: ['channel_id', 'period_id']

  triggers:
    conversionSummary: (model) ->
      if model.get('stage_id').isTopline()
        @update model.get('channel_id'), model.get('period_id')

    conversionForecast: (model) ->
      if model.get('stage_id').isTopline()
        @update model.get('channel_id'), model.get('period_id')

  calculate: (channel_id, period_id) ->
    result = {}
    where =
      stage_id: app.stages.topline().get('id')
      channel_id: channel_id
      period_id: period_id
    result['actual'] = _.first(app.conversionSummary.where(where))
      .get('customer_volume')
    result['plan'] = _.first(app.conversionForecast.where(where))
      .get('value')
    if result['plan']? and result['actual']?
      result['variance'] = result['plan'] - result['actual']
    result

    # if monthId is 1
    #   app.initialVolume.get(32943, channelId, segmentId) - \
    #   app.churnForecast.get(channelId, segmentId, monthId) + \
    #   app.conversionForecast.get(32943, channelId, segmentId, monthId)
    # else
    #   previousMonth = monthId - 1
    #   @get(channelId, segmentId, previousMonth) + \
    #   app.conversionForecast.get(32943, channelId, segmentId, monthId) - \
    #   app.churnForecast.get(channelId, segmentId, monthId)

  #
  # initialize: ->
  #   toplineStageId = app.stages.topline()?.id
  #
  #   @setBackbone app.conversionSummary,  stage_id: toplineStageId
  #   @setBackbone app.conversionForecast, stage_id: toplineStageId
