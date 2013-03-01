class TestsView extends Backbone.View
  el: '#container'
  printTemplate: _.template \
    '''
      <b>Local sets:</b><%= collection.localSetCounter %>
      <b>Local gets:</b><%= collection.localGetCounter %>
      <b>Total sets:</b><%= app.setCounter %>
      <b>Total gets:</b><%= app.getCounter %>
      <hr>
      <b>Local gets/sets:</b><%= (collection.localGetCounter/collection.localSetCounter).toFixed(2) %>
      <b>Total gets/sets:</b><%= (app.getCounter/app.setCounter).toFixed(2) %>
      <b>Sets total/local:</b><%= (app.setCounter/collection.localSetCounter).toFixed(2) %>
      <b>Gets total/local:</b><%= (app.getCounter/collection.localGetCounter).toFixed(2) %>

      <b>Min time:</b><%= _(times).min() %>ms || <%= (_(times).min()/1000).toFixed(2) %>s
      <b>Max time:</b><%= _(times).max() %>ms || <%= (_(times).max()/1000).toFixed(2) %>s
      <b>Avr time:</b><%= average %>ms || <%= (average/1000).toFixed(2) %>s
      <hr>
      <b>Total time:</b><%= time %>ms || <%= (time/1000).toFixed(2) %>s
    '''
  #printTemplate: JST['app/tests/print']

  events:
    'submit'       : 'runRandomizeTest'
    'click .clear' : 'clear'

  initialize: ->
    $('li.test_data').addClass('active')

  runRandomizeTest: (event) ->
    event.preventDefault()
    id         = event.target.id
    count      = parseInt @$("##{id}Input").val()
    collection = app[id]
    startTime  = (new Date).getTime()
    eventsLog  = []

    @addCounters(collection)

    _(count).times =>
      args  = (@getRandomId(inputs) for inputs in collection.collections)
      value = @getRandomInt(0, 100)
      @run collection, eventsLog, value, args...

    @printResults(id, count, collection, startTime, eventsLog)

  run: (collection, eventsLog, value, args...) ->
    startTime = (new Date).getTime()
    collection.set value, args...
    eventsLog.push
      value: value,
      args: args,
      time: (new Date).getTime() - startTime

  getRandomInt: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  getRandomId: (collection) ->
    position = @getRandomInt(0, collection.length - 1)
    collection[position].id

  printResults: (id,count,collection,startTime,eventsLog)->
    time = (new Date).getTime() - startTime
    @$("##{id}Results").html @printTemplate
      count: count,
      time: time,
      collection: collection,
      average: time/count,
      times: _(eventsLog).pluck('time')

  clear: (event) ->
    event.preventDefault()
    id = $(event.target).attr('data-id')
    @$("##{id}Results").html('')

  addCounters: (collection) ->
    unless collection.defaultSet
      collection.defaultSet = collection.set
    unless collection.defaultGet
      collection.defaultGet = collection.get
    [collection.localSetCounter, collection.localGetCounter] = [0, 0]
    collection.set = (value, args...)->
      @localSetCounter += 1
      @defaultSet(value, args...)
    collection.get = (args...)->
      @localGetCounter += 1
      @defaultGet(args...)

    Striker.Collection = Striker.Collection
    unless Striker.Collection::oldGet
      Striker.Collection::oldGet = Striker.Collection::get
    unless Striker.Collection::oldSet
      Striker.Collection::oldSet = Striker.Collection::set
    [app.setCounter, app.getCounter] = [0, 0]
    Striker.Collection::set = (value, args...)->
      app.setCounter +=1
      @oldSet(value, args...)
    Striker.Collection::get = (args...)->
      app.getCounter +=1
      @oldGet(args...)
