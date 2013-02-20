class ConversionForecast extends BaseCollection
  name: 'conversionForecast'
  schema: ['stageId', 'channelId', 'segmentId', 'monthId']

  triggers:
    this: (args) ->
      if stage = app.stages.at(_.indexOf(app.stages.pluck('id'), args.stageId) + 1)
        args.monthId += 1 unless stage.get('is_customer')
        @update(stage.id, args.channelId, args.segmentId, args.monthId) if args.monthId <= 36

    toplineGrowth: (args) ->
      for stage in app.stages.where(is_topline: true)
        for segment in app.segments.models
          @update(stage.id, args.channelId, segment.id, args.monthId)

    channelSegmentMix: (args) ->
      for stage in app.stages.where(is_topline: true)
        for month in app.months.models
          @update(stage.id, args.channelId, args.segmentId, month.id)

    conversionRates: (args) ->
      for segment in app.segments.models
        @update(args.notFirstStageId, args.channelId, segment.id, args.monthId)

  calculate: (stageId, channelId, segmentId, monthId) ->
    stage = app.stages.get(stageId)
    if stage.get('is_topline')
      app.toplineGrowth.get(channelId, monthId) * app.channelSegmentMix.get(channelId, segmentId)
    else
      previousStage = app.stages.at(app.stages.indexOf(stage) - 1)
      # TODO: strange logic with is_customer
      if monthId is 1 and !stage.get('is_customer')
        app.initialVolume.get(previousStage.id, channelId, segmentId) * \
        app.conversionRates.get(stageId, channelId, monthId)
      else
        # TODO: strange logic with monthOffset
        monthOffset = if stage.get('is_customer') then 0 else 1
        @get(previousStage.id, channelId, segmentId, monthId - monthOffset) * \
        app.conversionRates.get(stageId, channelId, monthId)
