module.exports = class Period extends Backbone.Model
  # Returns formated first_day attribute
  #
  # period = new Period(first_day: '2012-01-01')
  # period.month()
  # #=> "Jan 12"
  month: ->
    firstDay = @get('first_day')
    moment(firstDay).format('MMM YY')

  notFuture: ->
    app.periods.notFuture(@get('id'))

  # provides an integer for a given period specifying the number of periods
  #   between the current period and the specified period. past periods are
  #   returned as negative integers, and the current period is 0
  index: ->
    periodFirstDay = moment @get('first_day')
    startOfMonth = moment().startOf('month')
    switch
      when periodFirstDay < startOfMonth
        -1 * app.periods.chain()
              .select((period) ->
                firstDay = moment period.get('first_day')
                (firstDay >= periodFirstDay) and (firstDay < startOfMonth)
              )
              .value()
              .length
      when periodFirstDay > startOfMonth
        app.periods.chain()
          .select((period) ->
            firstDay = moment period.get('first_day')
            (firstDay >= startOfMonth) and (firstDay < periodFirstDay)
          )
          .value()
          .length
      else
        0
