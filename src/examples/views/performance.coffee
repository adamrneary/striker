module.exports = class PerformanceView extends Backbone.View
  el: '#container'
  printTemplate: _.template \
    '''
      <b>Local sets: </b><%= striker.localSetCounter %>
      <b>Local gets: </b><%= striker.localGetCounter %>
      <hr>
      <b>Min time: </b><%= _(times).min() %>ms
      <b>Max time: </b><%= _(times).max() %>ms
      <b>Avr time: </b><%= average %>ms
      <hr>
      <b>Total time: </b><%= time %>ms
    '''

  events:
    'submit'       : 'runRandomizeTest'
    'click .clear' : 'clear'

  initialize: ->
    $('li.test_data').addClass('active')

  runRandomizeTest: (event) ->
    event.preventDefault()
    id        = event.target.id
    count     = parseInt @$("##{id}Input").val()
    striker   = app[id]
    startTime = (new Date).getTime()
    eventsLog = []

    @addCounters(striker)
    @runTestsFor(striker, eventsLog, count)
    @printResults(id, count, striker, startTime, eventsLog)

  printResults: (id, count, striker, startTime, eventsLog) ->
    time = (new Date).getTime() - startTime
    @$("##{id}Results").html @printTemplate
      count: count
      time: time
      striker: striker
      average: time/count
      times: _(eventsLog).pluck('time')

  clear: (event) ->
    event.preventDefault()
    id = $(event.target).attr('data-id')
    @$("##{id}Results").html('No results')

  addCounters: (striker) ->
    striker.defaultSet = striker.set unless striker.defaultSet
    striker.defaultGet = striker.get unless striker.defaultGet

    [striker.localSetCounter, striker.localGetCounter] = [0, 0]
    striker.set = (value, args...)->
      @localSetCounter += 1
      @defaultSet(value, args...)
    striker.get = (args...)->
      @localGetCounter += 1
      @defaultGet(args...)

  runTestsFor: (striker, eventsLog, count) ->
    _(count).times =>
      time  = (new Date).getTime()
      value = _.random(0, 100)
      [collection, field] = if striker.constructor.name is 'Revenue'
        [app.financialSummary, 'amount_cents']
      else
        [
          [app.conversionSummary, 'customer_volume'],
          [app.conversionForecast, 'value']
        ][_.random(0,1)]

      position = _.random(0, collection.length - 1)
      model    = collection.at(position)
      model.set(field, value)
      eventsLog.push value: value, time: ((new Date).getTime() - time)
