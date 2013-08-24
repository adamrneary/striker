# define namespace for entries
window.entries = {}

# Stub collections
entries.Scenario           = Backbone.Model.extend({})
entries.Channels           = Backbone.Collection.extend({})
entries.ConversionSummary  = Backbone.Collection.extend({})
entries.ConversionForecast = Backbone.Collection.extend({})

entries.Stages = Backbone.Collection.extend({
  topline: ->
    @max (stage) -> stage.get('position')
})

entries.Periods = Backbone.Collection.extend({
  comparator: (period) ->
    moment(period.get('first_day')).unix()

  ids: ->
    @pluck('id')

  idToUnix: (periodId) ->
    moment(@get(periodId).get('first_day')).add('days', 1).unix() * 1000

  notFuture: (periodId) ->
    moment(@get(periodId).get('first_day')) <= @_startOfMonth()
})

Striker.sum = `function(collection, field) {
  return collection.reduce(function(memo, item){
    return memo + item.get(field);
  }, 0);
};`

entries.Reach = Striker.extend
  schema: ['channel_id', 'period_id']

  observers:
    conversionSummary:  (model, changed) ->
      return unless model.get('stage_id') is @cache('toplineId')
      @update(model.get('channel_id'), model.get('period_id'))

    conversionForecast: (model, changed) ->
      return unless model.get('stage_id') is @cache('toplineId')
      @update(model.get('channel_id'), model.get('period_id'))

  calculate: (channelId, periodId) ->
    summaryConditions =
      stage_id:   app.stages.topline().id
      channel_id: channelId
      period_id:  periodId

    conversionSummary  = app.conversionSummary.where(summaryConditions)
    forecastConditions = _.extend(summaryConditions, { scenario_id: app.scenario.id })
    conversionForecast = app.conversionForecast.where(forecastConditions)

    actual    = Striker.sum(conversionSummary, 'customer_volume')
    plan      = Striker.sum(conversionForecast, 'value')
    notFuture = app.periods.notFuture(periodId)

    period_id:  periodId
    periodUnix: app.periods.idToUnix(periodId)
    channel_id: channelId
    actual:     if notFuture then actual else undefined
    plan:       plan
    variance:   if notFuture then actual - plan else undefined
