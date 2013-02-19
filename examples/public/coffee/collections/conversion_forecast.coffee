ForecastCollection = require('./shared/forecast_collection')

module.exports = class ConversionForecast extends ForecastCollection
  name: 'conversionForecast'
  schema: ['stageId', 'channelId', 'segmentId', 'monthId']

  triggers:
    this: (args) ->
      if stage = admin.stages.at(_.indexOf(admin.stages.pluck('id'), args.stageId) + 1)
        args.monthId += 1 unless stage.get('is_customer')
        @set(stage.id, args.channelId, args.segmentId, args.monthId) if args.monthId <= 36

    toplineGrowth: (args) ->
      for stage in admin.stages.where(is_topline: true)
        for segment in admin.segments.models
          @set(stage.id, args.channelId, segment.id, args.monthId)

    channelSegmentMix: (args) ->
      for stage in admin.stages.where(is_topline: true)
        for month in admin.months.models
          @set(stage.id, args.channelId, args.segmentId, month.id)

    conversionRates: (args) ->
      for segment in admin.segments.models
        @set(args.notFirstStageId, args.channelId, segment.id, args.monthId)

  calculate: (stageId, channelId, segmentId, monthId) ->
    stage = admin.stages.get(stageId)
    if stage.get('is_topline')
      admin.toplineGrowth.get(channelId, monthId) * admin.channelSegmentMix.get(channelId, segmentId)
    else
      previousStage = admin.stages.at(admin.stages.indexOf(stage) - 1)
      # TODO: strange logic with is_customer
      if monthId is 1 and !stage.get('is_customer')
        admin.initialVolume.get(previousStage.id, channelId, segmentId) * \
        admin.conversionRates.get(stageId, channelId, monthId)
      else
        # TODO: strange logic with monthOffset
        monthOffset = if stage.get('is_customer') then 0 else 1
        @get(previousStage.id, channelId, segmentId, monthId - monthOffset) * \
        admin.conversionRates.get(stageId, channelId, monthId)
