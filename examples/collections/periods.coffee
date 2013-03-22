module.exports = class Periods extends Backbone.Collection
  isFuture: (periodId) ->
    firstDay = @get(periodId).get('first_day')
    new Date(firstDay) - 1 > Date.now()
