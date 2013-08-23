# define namespace for entries
window.entries = {}

# Stub collections
entries.Periods            = Backbone.Collection.extend({})
entries.Channels           = Backbone.Collection.extend({})
entries.Stages             = Backbone.Collection.extend({})
entries.Scenario           = Backbone.Collection.extend({})
entries.ConversionSummary  = Backbone.Collection.extend({})
entries.ConversionForecast = Backbone.Collection.extend({})

entries.Reach = Striker.extend
  schema: ['channel_id', 'period_id']

  indexes:
    'conversionForecast': ['stage_id', 'channel_id', 'period_id']
    'conversionSummary':  ['stage_id', 'channel_id', 'period_id']

  observers:
    conversionSummary:  (model, changed) ->
      return unless model.get('stage_id') is @cache('toplineId')
      @update(model.get('channel_id'), model.get('period_id'))

    conversionForecast: (model, changed) ->
      return unless model.get('stage_id') is @cache('toplineId')
      @update(model.get('channel_id'), model.get('period_id'))

  calculate: (channelId, periodId) ->
    summaryConditions =
      stage_id:   @cache('toplineId')
      channel_id: channelId
      period_id:  periodId

    conversionSummary  = Striker.where('conversionSummary',  summaryConditions)
    forecastConditions = _.extend(summaryConditions, { scenario_id: app.scenario.id })
    conversionForecast = Striker.where('conversionForecast', forecastConditions)

    actual    = Striker.sum(conversionSummary, 'customer_volume')
    plan      = Striker.sum(conversionForecast, 'value')
    notFuture = app.periods.notFuture(periodId)

    period_id:  periodId
    periodUnix: app.periods.idToUnix(periodId)
    channel_id: channelId
    actual:     if notFuture then actual else undefined
    plan:       plan
    variance:   if notFuture then actual - plan else undefined
