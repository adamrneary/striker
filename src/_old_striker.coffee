# The top-level namespace. All public Striker classes and modules will
# be attached to this. Exported for both CommonJS and the browser.
Striker = undefined
if typeof exports isnt 'undefined'
  Striker = exports
else
  Striker = window.Striker = {}

# Current version of the library.
Striker.VERSION = "0.3.0"

# Striker.Collection
# ------------------
class Striker.Collection

  # Include methods from Backbone.Events to support events
  _.extend(@::, Backbone.Events)

  # List of fields for group
  groupBy: ['period_id']

  # Default initialization
  initialize: ->

  # Init @values and calls `initialize`
  # initialize - is a constructor for inherited analysis
  constructor: (options = {}) ->
    if _.isArray(options.groupBy)
      @groupBy = _.uniq options.groupBy.concat(@groupBy)

    @values = @_initValues()
    @initialize(options)
    @_runCalculations(options)

  # Add analyse to Backbone.Model
  #
  # method  - method name
  # options - specific for analysis options
  #
  # Returns object with method name
  @extend: (methodName, options) ->
    getAnalyse = =>
      options.default = false
      @["#{methodName}-#{options.name}"] ||= new @(options)

    utils.object methodName, (range) ->
      analyse = getAnalyse()
      values  = analyse.get(@id)

      analyse.get range, @, (periodId) =>
        for option in ['actual', 'plan'] when options[option]
          value = options[option].call(@, periodId)
          value = utils.object(option, value) unless _.isObject(value)
          analyse.set periodId, value, values

        analyse.set periodId, analyse.calc?.call(@, periodId), values if analyse.calc
        values[periodId]

  # Convinient way to get access to @values
  #
  # range - array of period ids or singe periodId
  #
  # Examples:
  #
  #   @get('2012-02')
  #   # => 40
  #
  #   @get(['2012-01', '2012-02'])
  #   # => {
  #         2012-01: {actual: 20, plan: 0}
  #         2012-02: {actual: 10, plan: 12}
  #        }
  #
  #   @get()
  #   # => [
  #         {periodId: '2012-01', actual: 20, plan: 0}
  #         {periodId: '2012-02', actual: 10, plan: 12}
  #        ]
  #
  # Returns object or list of objects
  get: (range = [], context = @, getValue) ->
    getValue ||= (periodId) => @values[periodId]
    if _.isArray(range)
      if range.length is 0
        result = []
        for periodId in app.periods.ids()
          result.push _.extend(getValue.call(context, periodId), periodId: periodId)
      else
        result = {}
        for periodId in range
          result[periodId] = getValue.call(context, periodId)
      result
    else
      getValue.call(context, range)

  set: (periodId, value, values = @values) ->
    values[periodId] = utils.merge values[periodId], value

  # Assigns values from filtered collection to correct place in @values
  setValuesForArray: (collection, options) ->
    items = collection
    items = utils.filter(items, options.conditions) if options.conditions
    items = utils.mapped(items, options.mapped, app[@_schema[options.mapped.from]]) if options.mapped

    for item in items
      value  = options.getValue(item) || {}
      values = @values
      values = values[item[key]] for key in @groupBy.slice(0, -1)
      utils.handle values[item[@groupBy.slice(-1)]], value if values

  setValues: (collection, conditions = null, mapped = null) ->
    getValue = collection.getValue()
    unless _.isArray(collection)
      collection = collection.map (item) -> item.attributes

    @setValuesForArray collection,
      conditions: conditions,
      mapped: mapped,
      getValue: getValue

  getBySchema: (schemaId) ->
    switch schemaId
      when 'stage_not_topline_id' then app.stages.notToplineIds()
      else app[@_schema[schemaId]]?.ids()

  #
  # PRIVATE
  #

  _schema:
    'period_id'   : 'periods'
    'channel_id'  : 'channels'
    'segment_id'  : 'segments'
    'customer_id' : 'customers'
    'stage_id'    : 'stages'

  _initValues: (values = {}, level = 0) ->
    collectionIds = @getBySchema(@groupBy[level])
    return unless collectionIds

    for itemId in collectionIds
      values[itemId] = {}
      if level isnt @groupBy.length - 1
        @_initValues values[itemId], level + 1
    values

  _runCalculations: (options) ->
    for method in ['default', 'actual', 'plan']
      @[method]?() if _.isUndefined(options[method])

# Striker.utils
# ------------------
Striker.utils = utils =
  object: (prop, value) ->
    result = {}
    result[prop] = value
    result

  sum: (object) ->
    _.reduce object, ((memo, val) -> memo += val), 0

  specialCondition: (value) ->
    if value
      if _(value).has('actual') then value.actual else value.plan
    else 0

  handle: (object, value) ->
    if object
      for key, val of value
        object[key] ||= 0
        object[key] += val

  merge: (value, part) ->
    if _.isArray(part)
      part
    else
      for key in _.keys(part)
        if _.isObject value[key]
          @merge value[key], part[key]
        else
          value[key] = part[key]
      value

  filter: (collection, conditions) ->
    _(collection).select (item) ->
      for key, value of conditions
        if _.isArray(value)
          return false unless _.include value, item[key]
        else
          return false unless value is item[key]
      return true

  mapped: (items, map, collectionFrom) ->
    for item in items
      id     = item[map.from]
      joinId = collectionFrom.get(id).get(map.to)
      item[map.to] = joinId
    items

# # bulk return
# # ------------------

# # Combine information for display
# #
# # Returns array of nested arrays
# print: (result = [], args = [], level = 0) ->
#   for item in @collections[level]
#     args[level] = item.id
#     if level >= @schema.length - 2 and @isTimeSeries()
#       result.push args.concat _.values(@get(args...))
#     else if level >= @schema.length - 1 and !@isTimeSeries()
#       result.push args.concat @get(args...) * @multiplier
#     else
#       @print(result, args, level + 1)
#   result

# # Flattens output of print to single objects with keys informed by schema
# #
# # Returns Array of Objects
# toArray: ->
#   _.map @print(), (item) =>
#     result = {}
#     for key, index in @schema
#       if key is 'period_id'
#         for i, index2 in _.range(index, @print()[0].length)
#           result[index2] = item[i]
#         return result
#       else
#         result[key] = item[index]
#     result['value'] = item[@schema.length]
#     result