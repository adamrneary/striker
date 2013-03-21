class App.Collections.ConversionForecast extends Striker.Collection
  schema: ['stageId', 'channelId', 'segmentId', 'monthId']

  triggers:
    this: (args) ->
      index = _.indexOf(app.stages.pluck('id'), args.stageId) + 1
      if stage = app.stages.at(index)
        args.monthId += 1 unless stage.get('is_customer')
        if args.monthId <= 36
          @update(stage.id, args.channelId, args.segmentId, args.monthId)

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
      a = app.toplineGrowth.get(channelId, monthId)
      b = app.channelSegmentMix.get(channelId, segmentId)
      result = a * b
    else
      previousStage = app.stages.at(app.stages.indexOf(stage) - 1)
      # TODO: strange logic with is_customer
      if monthId is 1 and !stage.get('is_customer')
        a = app.initialVolume.get(previousStage.id, channelId, segmentId)
        b = app.conversionRates.get(stageId, channelId, monthId)
        result = a * b

      else
        # TODO: strange logic with monthOffset
        monthOffset = if stage.get('is_customer') then 0 else 1
        a = @get(previousStage.id, channelId, segmentId, monthId - monthOffset)
        b = app.conversionRates.get(stageId, channelId, monthId)
        result = a*b

    Math.round(result)
