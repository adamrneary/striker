module.exports = class Periods extends Backbone.Collection
  isFuture: (periodId) ->
    firstDay = @get(periodId).get('first_day')
    @compare(new Date(firstDay), new Date())

  idToDate: (periodId) ->
    @get(periodId).get('first_day')

  # Easy stub
  compare: (date1, date2) ->
    date1.getTime() - 1 > date2.getTime()
