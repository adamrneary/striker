ForecastCollection = require('./shared/forecast_collection')

module.exports = class ChurnForecast extends ForecastCollection
  name: 'churnForecast'
  schema: ['channelId', 'segmentId', 'monthId']

  triggers:
    customerForecast: (args) ->
      @set(args.channelId, args.segmentId, args.monthId + 1) if args.monthId isnt 36

    initialVolume: (args) ->
      @set(args.channelId, args.segmentId, 1) if args.stageId is 32943

    churnRates: (args) ->
      @set(channel.id, args.segmentId, args.monthId) for channel in app.channels.models

  calculate: (channelId, segmentId, monthId) ->
    # TODO: strange logic with stage.id, stub it to 32943
    if monthId is 1
      app.churnRates.get(segmentId, monthId) * app.initialVolume.get(32943, channelId, segmentId)
    else
      previousMonth = monthId - 1
      app.customerForecast.get(channelId, segmentId, previousMonth) * app.churnRates.get(segmentId, monthId)
