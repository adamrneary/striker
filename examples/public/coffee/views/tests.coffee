class TestsView extends Backbone.View
  el: '#container'
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
    eventsLog.push value: value, args: args, time: (new Date).getTime() - startTime

  getRandomInt: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  getRandomId: (collection) ->
    position = @getRandomInt(0, collection.length - 1)
    collection[position].id

  printResults: (id, count, collection, startTime, eventsLog) ->
    time = (new Date).getTime() - startTime
    @$("##{id}Results").html @printTemplate
      count: count, time: time, collection: collection, average: time/count, times: _(eventsLog).pluck('time')

  clear: (event) ->
    event.preventDefault()
    id = $(event.target).attr('data-id')
    @$("##{id}Results").html('')

  addCounters: (collection) ->
    collection.defaultSet = collection.set unless collection.defaultSet
    collection.defaultGet = collection.get unless collection.defaultGet
    [collection.localSetCounter, collection.localGetCounter] = [0, 0]
    collection.set = (value, args...) -> @localSetCounter += 1; @defaultSet(value, args...)
    collection.get = (args...)        -> @localGetCounter += 1; @defaultGet(args...)

    baseCollection = BaseCollection
    baseCollection::oldGet = baseCollection::get unless baseCollection::oldGet
    baseCollection::oldSet = baseCollection::set unless baseCollection::oldSet
    [app.setCounter, app.getCounter] = [0, 0]
    baseCollection::set = (value, args...) -> app.setCounter +=1; @oldSet(value, args...)
    baseCollection::get = (args...) -> app.getCounter +=1; @oldGet(args...)
