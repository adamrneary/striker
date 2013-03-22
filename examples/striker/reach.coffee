observer = (value) ->
  (model, changed) ->
    toplineId = app.channels.toplineId()
    return unless model.get('stage_id') is toplineId

    if _.has(changed, value)
      @update(model.get('channel_id'), model.get('period_id'))

module.exports = class Reach extends Striker.Collection
  schema: ['channel_id', 'period_id']

  observers:
    conversionSummary:  observer('customer_volume')
    conversionForecast: observer('value')

  calculate: (channelId, periodId) ->
    toplineId          = app.channels.toplineId()
    isFuture           = app.periods.isFuture(periodId)
    conversionSummary  = Striker.filter('conversionSummary',  stage_id: toplineId, channel_id: channelId, period_id: periodId)
    conversionForecast = Striker.filter('conversionForecast', stage_id: toplineId, channel_id: channelId, period_id: periodId)

    result = {}
    result.actual   = Striker.sum(conversionSummary, 'customer_volume') unless isFuture
    result.plan     = Striker.sum(conversionForecast, 'value')
    result.variance = result.actual - result.plan unless isFuture
    result
