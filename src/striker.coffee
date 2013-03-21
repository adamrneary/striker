# Striker.js 0.1.0
# Bad-ass, greasy-fast, cached calculated collections
# (c) 2013 Adam Neary & Aleksey Kulikov, Profitably Inc.

# The top-level namespace. All public Striker classes and modules will
# be attached to this. Exported for both CommonJS and the browser.
Striker = undefined
if typeof exports isnt 'undefined'
  Striker = exports
else
  Striker = window.Striker = {}

# Current version of the library.
Striker.VERSION = "0.3.0"

schemaMap = ->
  throw new Error('Setup your striker mapping with Striker.setSchemaMap')

# Setup schema mapping in order to work
# with Striker.Collection.prototype.schema
Striker.setSchemaMap = (cb) ->
  schemaMap = cb

# Striker.Collection
# ------------------
#
# Wrapper for multidimensional arrays. Since in javascript, arrays are
# objects (with specific keys), it will not hamper perfomance to store
# data as an object rather than an array.
#
# schema     - Sets order and type nested attributes (required)
#              data save based on this attribute
# multiplier - For percentage data equal 100, by default 1
# triggers   - Object with functions which called when object was changed
#              use short versions of variables from app
#
# Examples
#
#   class ConversionRates extends Striker.Collection
#     schema: ['stage_id', 'channel_id', 'period_id']
#     multiplier: 100
#     triggers:
#       toplineGrowth: (args) ->
#         l("toplineGrowth changed with channel: #{args.channel_id}")
#
#   conversionRates = new ConversionRates()
#   conversionRates.collections
#   # =>  [
#           Array[stages.length]
#           Array[channels.length]
#           Array[months.length]
#         ]
#
#   conversionRates.values
#   # => object with data
#   2: # stage id
#     1: # channel id, contains values for every month
#       1:  70 # first month id with value
#       2:  17 # second month id with value
#       #   ...
#       36: 27 # last month id with value
#     2:
#       1:  46
#       2:  66
#       #   ...
#       36: 14
#     # other channels with data for stage with id = 2
#   3: # another stage id
#     1: # channels for another stage
#       1:  16
#       #   ...
#       36: 34
#     # other channels with data for stage with id = 3
#   # other stages...
#
#   # Get value for stage_id = 2 and channel_id = 1 and period_id = 36
#   conversionRates.get(2, 1, 36)
#   # => 27
#
#   # Set 75% for stage_id = 3, channel_id = 1 and period_id = 1
#   conversionRates.set(75, 3, 1, 1)
#
#   conversionRates.isTimeSeries()
#   # => true
#
#   conversionForecast.enableTriggers()
#   app.toplineGrowth.set(5, 1, 2, 3)
#   # => 'toplineGrowth changed with channel: 2'
class Striker.Collection

  # Include methods from Backbone.Events for binding support
  _.extend(@::, Backbone.Events)

  # Set default multiplier to 1 to avoid altering data unless requested
  multiplier: 1

  # Collections with schemas ending with this are treated as time series
  timeSeriesIdentifier: 'period_id'

  # Array with collection IDs that setups with Striker.setSchemaMap
  # CRITICAL: Override this in each subclass.
  #
  # Example
  #
  #   Striker.setSchemaMap (key) ->
  #     stage_id:   app.stages
  #     channel_id: app.channels
  #     period_id:  app.months
  #
  #   class ConversionRates extends Striker.Collection
  #     schema: ['stage_id', 'channel_id', 'period_id']
  #
  #   conversionRates = new ConversionRates()
  #   conversionRates.collections
  #   # =>  [
  #           Array[stages.length]
  #           Array[channels.length]
  #           Array[months.length]
  #         ]
  #
  schema: []

  # Object with functions which called when object was changed.
  # CRITICAL: Override this in each subclass.
  #
  # key   - collection name
  # value - function taking filter args Object as param
  #
  # Example
  observers: {}

  # Builds striker based on inputs (optionally) and schema
  #
  # @inputs - optional mechanism for loading collection with data
  #   Note: data should be in nested Arrays matching schema and schema
  #   collections
  #
  # Examples
  #
  #   class ChannelSegmentMix extends Striker.Collection
  #     schema: ['channel_id', 'segment_id']
  #
  #   app.channels.length
  #   # => 5
  #   app.segments.length
  #   # => 3
  #
  #   data: [
  #     [100,0,0]
  #     [25,25,50]
  #     [0,100,0]
  #     [20,40,40]
  #     [30,5,65]
  #   ]
  #   channelSegmentMix = new ChannelSegmentMix(data)
  #
  # Note: Pass no data if the collection will be populated by calcuations
  #   In this case, the collection will be initialized with 0 values until
  #   observers are turned on and values can be calculated.
  constructor: (@inputs = [])->
    @collections = _.map @schema, schemaMap
    @values      = @_initValues()

  # Raw method for calculating a forecast value.
  # CRITICAL: Override this in each subclass.
  #
  # args - One or more attributes from @schema
  #
  # Returns value to cache (type may vary based on what you wish to cache)
  calculate: (args...) ->

  # Check that collection has period_id attribute
  #
  # Returns true or false
  isTimeSeries: ->
    _.last(@schema) is @timeSeriesIdentifier

  # get/set/update
  # ------------------

  # Get value by params
  #
  # args - Arguments split by commas and bases on schema.
  #        If schema is ['channel_id', 'period_id']
  #        then get(1,2) will be equal channel_id=1 and period_id=2
  #
  # Examples
  #
  #   conversionRates.get(2, 1, 1)
  #   # => 70
  #
  #   conversionRates.get(2, 1)
  #   # => {1: 70, 2: 17, ..., 36: 27}
  #
  # Returns value or object with group of values
  get: (args...) ->
    result = @values
    result = result[key] for key in args
    result = result / @multiplier if _.isNumber(result)
    result

  # Changes value and fire trigger `change`
  #
  # value - New value
  # args  - Arguments split a comma and bases on schema
  #         for navigation to specifically value.
  #
  # Examples
  #
  #   conversionRates.set(45, 2, 1, 1)
  #   conversionRates.get(2, 1, 1)
  #   # => 45
  #
  # Returns nothing.
  set: (value, args...) ->
    result = @values
    result = result[key] for key in args.slice(0, -1)
    result[_.last(args)] = value
    @trigger('change', @, args, value)

  # Triggers a set for the collection's item as filtered by args
  #
  # args - Arguments split by commas and bases on schema.
  #        If schema is ['channel_id', 'period_id']
  #        then get(1,2) will be equal channel_id=1 and period_id=2
  #
  # Note: This acts to refresh the cached data and is generally called
  #       proactively by a trigger after making a change to underlying data
  #
  # Examples
  #
  #   conversionRates.get(2, 1)
  #   # => 10
  #   conversionRates.calculate(2, 1)
  #   # => 12
  #   conversionRates.update(2, 1)
  #   conversionRates.get(2, 1)
  #   # => 12
  #
  # Returns nothing
  update: (args...) ->
    @set @calculate(args...), args...

  # bulk return
  # ------------------
  flat: (level = 0, args = [], result = []) ->
    for item in @collections[level]
      args[level] = item.id
      if level < @schema.length - 1
        @flat(level + 1, args, result)
      else
        object = {}
        object[@schema[index]] = value for value, index in args
        result.push _.extend(object, @get.apply(@, args))
    result

  # observers and event handling
  # ------------------

  # Setup collection observers based on @observers property.
  # Name `this` uses for self reference
  # And than build values with `calculate` method
  #
  # We can build values in constructor because we need initialize all necessary collections
  # Often calculate method refer recursively.
  enable: ->
    for collectionName, callback of @observers
      # TODO: don't use app as a global namespace
      collection = if collectionName is 'this' then @ else app[collectionName]
      collection.on('change', @_wrapCallback(callback), @)
    @_build()

  # Recursive function which uses @inputs and @collections for builds @values
  # Attributes used for recursive callbacks
  #
  # Returns object with structured data
  _initValues: (values = {}, inputs = @inputs, level = 0) ->
    if @collections[level]
      for item, order in @collections[level]
        value = inputs[order] ? 0
        if @schema
          if level is @schema.length - 1
            values[item.id] = value
          else
            values[item.id] = {}
            @_initValues(values[item.id], value, level + 1)
    values

  # Builds values for every element
  _build: (level = 0, args = []) ->
    for item in @collections[level]
      args[level] = item.id
      if level >= @schema.length - 1
        @update(args...)
      else
        @_build(level + 1, args)

  # Private: pass changed attributes to observer
  #
  # Returns trigger function
  _wrapCallback: (defaultCallback) ->
    (model, args, value) ->
      if model instanceof Backbone.Model
        defaultCallback.call(@, model, model.changed)
      else
        defaultCallback.call(@, model, args, value)

# Extend model with existing analysis
Striker.addAnalysis = (Model, methodName, options = {}) ->
  analysisName = options.analysis ? methodName
  Model.prototype[methodName] = (args...) ->
    app[analysisName].get.apply(app[analysisName], [@id].concat(args))

Striker.utils =
  where: (collection, attrs) ->
    collection.filter (model) ->
      for key of attrs
        if _.isArray(attrs[key])
          return false unless _.include(attrs[key], model.get(key))
        else
          return false unless attrs[key] is model.get(key)
      true

  sum: (collection, field) ->
    _.reduce collection, (memo, item) ->
      memo += item.get(field)
    , 0
