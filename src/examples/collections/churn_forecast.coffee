class App.Collections.ChurnForecast extends Striker.Collection
  schema: ['channelId', 'segmentId', 'monthId']

  triggers:
    customerForecast: (args) ->
      if args.monthId isnt 36
        @update(args.channelId, args.segmentId, args.monthId + 1)

    initialVolume: (args) ->
      if args.stageId is 32943
        @update(args.channelId, args.segmentId, 1)

    churnRates: (args) ->
      for channel in app.channels.models
        @update(channel.id, args.segmentId, args.monthId)

  calculate: (channelId, segmentId, monthId) ->
    # TODO: strange logic with stage.id, stub it to 32943
    if monthId is 1
      a = app.churnRates.get(segmentId, monthId)
      b = app.initialVolume.get(32943, channelId, segmentId)
      result = a*b
    else
      previousMonth = monthId - 1
      a = app.customerForecast.get(channelId, segmentId, previousMonth)
      b = app.churnRates.get(segmentId, monthId)
      result = a*b
    Math.round(result)
