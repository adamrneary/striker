module.exports = class Reach extends Striker.Collection
  schema: ['channel_id', 'period_id']

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