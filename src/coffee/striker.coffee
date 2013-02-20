# Striker.js 0.0.1
# Bad-ass, greasy-fast, cached calculated collections

# (c) 2013 Adam Neary, Profitably Inc.

  # initial setup (similar to backbone.js)
  # --------------------------------------

  # Save a reference to the global object (`window` in the browser, `exports`
  # on the server).
  root = this

  # Save the previous value of the `Striker` variable, so that it can be
  # restored later on, if `noConflict` is used.
  previousStriker = root.Striker

  # The top-level namespace. All public Striker classes and modules will
  # be attached to this. Exported for both CommonJS and the browser.
  Striker = undefined
  if typeof exports isnt "undefined"
    Striker = exports
  else
    Striker = root.Striker = {}

  # Current version of the library. Keep in sync with `package.json`.
  Striker.VERSION = "0.0.1"

  # For Striker's purposes, jQuery, Zepto, or Ender owns the `$` variable.
  Striker.$ = root.jQuery or root.Zepto or root.ender

  # Runs Striker.js in *noConflict* mode, returning the `Striker` variable
  # to its previous owner. Returns a reference to this Striker object.
  Striker.noConflict = ->
    root.Striker = previousStriker
    this

  # Striker.Collection
  # ------------------

  # Wrapper for multidimensional arrays. Since in javascript, arrays are
  # objects (with specific keys), it will not hamper perfomance to store
  # data as an object rather than an array.
  #
  # name       - Name of collection (required)
  # schema     - Sets order and type nested attributes (required)
  #              data save based on this attribute
  # multiplier - For percentage data equal 100, by default 1
  #
  # Examples
  #
  #   class ConversionRates extends Striker.Collection
  #     name: 'conversionRates'
  #     schema: ['stageId', 'channelId', 'monthId']
  #     multiplier: 100
  #
  #   conversionRates = new ConversionRates()
  #   conversionRates.collections
  #   # => [Array[stages.length], Array[channels.length], Array[months.length]]
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
  #
  #   # Get value for stageId = 2 and channelId = 1 and monthId = 36
  #   conversionRates.get(2, 1, 36)
  #   # => 27
  #
  #   # Set 75% for stageId = 3, channelId = 1 and monthId = 1
  #   conversionRates.set(75, 3, 1, 1)
  #
  #   conversionRates.isMonth()
  #   # => true
  class Striker.Collection

    # Include methods from Backbone.Events for binding support
    _.extend(@::, Backbone.Events)

    # Set default multiplier to 1 to avoid altering data unless requested
    multiplier: 1

    constructor: (@inputs = [])->
      @collections = (app.schemaMap(field) for field in @schema)
      @values      = @initValues()

    # Raw method for calculating a forecast value. Extend this.
    #
    # args - One or more attributes from @schema
    #
    # Returns value to cache (type may vary based on what you wish to cache)
    calculate: (args...) ->

    # Check that collection has monthId attribute
    #
    # Returns true or false
    isMonth: ->
      _.last(@schema) is 'monthId'

    # Recursive function which uses @inputs and @collections for builds @values
    # Attributes used for recursive callbacks
    #
    # Returns object with structured data
    initValues: (values = {}, inputs = @inputs, level = 0) ->
      for item, order in @collections[level]
        value = inputs[order] ? 0
        if level is @schema.length - 1
          values[item.id] = value
        else
          values[item.id] = {}
          @initValues(values[item.id], value, level + 1)
      values

    # Builds values for every element
    build: (level = 0, args = []) ->
      for item in @collections[level]
        args[level] = item.id
        if level >= @schema.length - 1
          @update(args...)
        else
          @build(level + 1, args)

    # get/set/update
    # ------------------

    # Get value by params
    #
    # args - Arguments split by commas and bases on schema.
    #        If schema is ['channelId', 'monthId']
    #        then get(1,2) will be equal channelId=1 and monthId=2
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
      @trigger('change', args, value, @)

    # Triggers a set for the collection's item as filtered by args
    #
    # args - Arguments split by commas and bases on schema.
    #        If schema is ['channelId', 'monthId']
    #        then get(1,2) will be equal channelId=1 and monthId=2
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

    # Combine information for display
    #
    # Returns array of nested arrays
    print: (result = [], args = [], level = 0) ->
      for item in @collections[level]
        args[level] = item.id
        if level >= @schema.length - 2 and @isMonth()
          result.push args.concat _.values(@get(args...))
        else if level >= @schema.length - 1 and !@isMonth()
          result.push args.concat @get(args...) * @multiplier
        else
          @print(result, args, level + 1)
      result

    # Flattens output of print to single objects with keys informed by schema
    #
    # Returns Array of Objects
    toArray: ->
      _.map @print(), (item) =>
        result = {}
        for key, index in @schema
          if key is 'monthId'
            for i, index2 in _.range(index, @print()[0].length)
              result[index2] = item[i]
            return result
          else
            result[key] = item[index]
        result['value'] = item[@schema.length]
        result




    # Turns On triggers based on @triggers. Name `this` uses for self triggers
    onTriggers: ->
      for collectionName, callback of @triggers
        collection = if collectionName is 'this' then @ else app[collectionName]
        collection.on('change', @wrapCallback(callback), @)

    # Private: pass args as object with params to trigger function
    #
    # Returns trigger function
    wrapCallback: (defaultCallback) ->
      (args, value, collection) ->
        attributes = {}
        attributes[key] = args[order] for key, order in collection.schema
        defaultCallback.call(@, attributes)


      # Adds specific forecast functionality to Striker.Collection
      #
      # name        - Forecast name (required)
      # schema      - Schema for attributes (required)
      # triggers    - Object with functions which called when object was changed
      #               use short versions of variables from app
      #
      # Examples
      #
      #   class ConversionForecast extends ForecastCollection
      #     name: 'conversionForecast'
      #     schema: ['stageId', 'channelId', 'segmentId', 'monthId']
      #     triggers:
      #       toplineGrowth: (args) -> l("toplineGrowth changed with #{args.channelId} and #{args.monthId}")
      #
      #   conversionForecast = new ConversionForecast()
      #
      #   # Build forecast based on current inputs
      #   conversionForecast.build()
      #
      #   # Turns on all triggers
      #   conversionForecast.onTriggers()
      #   app.toplineGrowth.set(5, 1, 1)
      #   # => 'toplineGrowth changed'