class CustomerForecast extends Striker.Collection
  schema: ['channelId', 'segmentId', 'monthId']

  triggers:
    churnForecast: (args) ->
      @update(args.channelId, args.segmentId, args.monthId)

    conversionForecast: (args) ->
      @update(args.channelId, args.segmentId, args.monthId) if args.stageId is 32943

  calculate: (channelId, segmentId, monthId) ->
    # TODO: strange logic with stage.id, stub it to 32943
    if monthId is 1
      app.initialVolume.get(32943, channelId, segmentId) - \
      app.churnForecast.get(channelId, segmentId, monthId) + \
      app.conversionForecast.get(32943, channelId, segmentId, monthId)
    else
      previousMonth = monthId - 1
      @get(channelId, segmentId, previousMonth) + \
      app.conversionForecast.get(32943, channelId, segmentId, monthId) - \
      app.churnForecast.get(channelId, segmentId, monthId)