Collection = require('lib/collection')
Period     = require('models/period')

module.exports = class Periods extends Collection
  url: 'api/v1/periods'
  model: Period

  # Order ascending by first_day
  comparator: (period) ->
    moment(period.get('first_day')).unix()

  # Uses as a filter
  #
  # start - Number of months from start
  # end   - Number of months to end
  #
  # Examples:
  #
  #   # current date is 2012-07-03
  #   periods.range(-3, -1)
  #   # => ['2012-04', '2012-05', '2012-06'] - ids of 3 last months
  #
  #   period.range(null, 0)
  #   # => ['2012-03', '2012-04', '2012-05', '2012-06', '2012-07'] - ids of all months to current
  #
  # Returns list of ids which contain current period
  range: (start, end) ->
    startOfMonth = @_startOfMonth().toString()
    startDate    = moment(startOfMonth).add('months', start)
    endDate      = moment(startOfMonth).add('months', end)

    @chain().select((period) ->
      firstDay = moment period.get('first_day')
      (_.isNull(start) or firstDay >= startDate) and (_.isNull(end) or firstDay <= endDate)
    ).pluck('id').value()

  currentRange: ->
    t = app.state.get('timeframe')
    app.periods.range(t[0], t[1])

  currentRangeAsTime: ->
    t = app.state.get('timeframe')
    [
      app.periods.indexToDate(t[0])?.getTime() / 1000
      app.periods.indexToDate(t[1])?.getTime() / 1000
    ]

  # Same as above but accepts number of milliseconds since the Unix Epoch
  rangeByDate: (startDate, endDate) ->
    return if isNaN(startDate) or isNaN(endDate)
    startDate = moment.unix startDate
    endDate = moment.unix endDate
    @chain().select((period) ->
      firstDay = moment period.get('first_day')
      (firstDay >= startDate) and (firstDay <= endDate)
    ).pluck('id').value()

  idToMonthString: (periodId) ->
    moment(@get(periodId).get('first_day')).format('MMM')

  idToMonthYearString: (periodId) ->
    moment(@get(periodId).get('first_day')).format('MMM YYYY')

  idToYearString: (periodId) ->
    moment(@get(periodId).get('first_day')).format('YYYY')

  idToCompactString: (periodId) ->
    value = moment(@get(periodId).get('first_day')).format('MMM')
    if value is 'Jan'
      value = moment(@get(periodId).get('first_day')).format('YYYY')
    value

  idToIndex: (periodId) ->
    @get(periodId).index()

  indexToDate: (index) ->
    moment().startOf('month').add('months', index).toDate()
    # d3.time.format("%Y-%m-%d").parse(
    #   moment().startOf('month').add('months', index).format('YYYY-MM-DD')
    # )

  indexToFirstDay: (index) ->
    moment().startOf('month').add('months', index).format('YYYY-MM-DD')

  idToDate: (periodId) ->
    d3.time.format("%Y-%m-%d").parse(@get(periodId).get('first_day'))

  notFuture: (periodId) ->
    moment(@get(periodId).get('first_day')) <= @_startOfMonth()

  _startOfMonth: ->
    moment().startOf('month')

  setAnalysis: (analysis) ->
    app.periods.eachIds (periodId) ->
      analysis.set periodId, analysis.calc(periodId)
