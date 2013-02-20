class IndexView extends Backbone.View
  el: '#container'
  monthCount: 36
  columns:
    streams: [
      id: "id"
      label: "ID"
      classes: "row-heading"
    ,
      id: "name"
      label: "Name"
    ]
    segments: [
      id: "id"
      label: "ID"
      classes: "row-heading"
    ,
      id: "name"
      label: "Name"
    ]
    channels: [
      id: "id"
      label: "ID"
      classes: "row-heading"
    ,
      id: "name"
      label: "Name"
    ]
    stages: [
      id: "id"
      label: "ID"
      classes: "row-heading"
    ,
      id: "name"
      label: "Name"
    ,
      id: "lag"
      label: "Lag"
    ,
      id: "is_topline"
      label: "Is topline"
    ,
      id: "is_customer"
      label: "Is customer"
    ]
    channelSegmentMix: [
      id: "channelId"
      label: "Channel id"
      classes: "row-heading"
    ,
      id: "segmentId"
      label: "Segment id"
      classes: "row-heading"
    ,
      id: "value"
      label: "Value"
    ]
    initialVolume: [
      id: "stageId"
      label: "Stage id"
      classes: "row-heading"
    ,
      id: "channelId"
      label: "Channel id"
      classes: "row-heading"
    ,
      id: "segmentId"
      label: "Segment id"
      classes: "row-heading"
    ,
      id: "value"
      label: "Value"
    ]
    toplineGrowth: [
      id: "channelId"
      label: "Channel id"
      classes: "row-heading"
      width: '70px'
    ]
    conversionRates: [
      id: "stageId"
      label: "Stage id"
      classes: "row-heading"
      width: '70px'
    ,
      id: "channelId"
      label: "Channel id"
      classes: "row-heading"
      width: '70px'
    ]
    churnRates: [
      id: "segmentId"
      label: "Segment id"
      classes: "row-heading"
      width: '70px'
    ]
    conversionForecast: [
      id: "stageId"
      label: "Stage id"
      classes: "row-heading"
      width: '70px'
    ,
      id: "segmentId"
      label: "Segment id"
      classes: "row-heading"
      width: '70px'
    ,
      id: "channelId"
      label: "Channel id"
      classes: "row-heading"
      width: '70px'
    ]
    customerForecast: [
      id: "channelId"
      label: "Channel id"
      classes: "row-heading"
      width: '70px'
    ,
      id: "segmentId"
      label: "Segment id"
      classes: "row-heading"
      width: '70px'
    ]
    churnForecast: [
      id: "channelId"
      label: "Channel id"
      classes: "row-heading"
      width: '70px'
    ,
      id: "segmentId"
      label: "Segment id"
      classes: "row-heading"
      width: '70px'
    ]

  render: ->
    @_renderInputs()
    @_renderForecasts()
    # @highlight()
    @

  _renderInputs: ->
    for input in ['streams', 'segments', 'channels', 'stages']
      @_renderBackboneCollection(app[input])
    for input in [
      'channelSegmentMix', 'initialVolume', 'toplineGrowth', 'conversionRates',
      'churnRates'
    ]
      @_renderStrikerCollection(app[input])

      # @makeInteractive(input) if input.schema

  _renderBackboneCollection: (collection) ->
    grid = new window.TableStakes()
      .el("##{collection.name}")
      .columns(@columns[collection.name])
      .data(collection.toJSON())
      .render()

  _renderStrikerCollection: (collection) ->
    columns = @columns[collection.name]
    columns = @_addMonths(columns) if _.last(collection.schema) is 'monthId'
    grid = new window.TableStakes()
      .el("##{collection.name}")
      .columns(columns)
      .data(collection.toArray())
      .render()

  _addMonths: (columns) ->
    _.times @monthCount, (i) =>
      columns.push {id: i, label: "#{i+1}"}
    columns

  _renderForecasts: ->
    new HighChart().render()

    for forecast in ['conversionForecast', 'churnForecast', 'customerForecast']
      @_renderStrikerCollection(app[forecast])








  highlight: ->
    $('''
      .channelSegmentMix td:last-child,
      .initialVolume td:last-child,
      .toplineGrowth td:not(:first-child),
      .conversionRates td:not(:first-child, :nth-child(2)),
      .churnRates td:not(:first-child)
    ''').addClass('yellow')

  makeInteractive: (collection) ->
    collection.on('change', @changeRow)
    dopSelector = if collection.isTimeSeries() then ':not(:first)' else ''

    $(".#{collection.name} tr:not(:first)#{dopSelector}").each ->
      [$tr, args, notPart] = [$(@), {}, '']

      for field, order in collection.schema
        notPart += ':not(:first)' if order > 0
        args[field] = $tr.find("td#{notPart}:first").html()

      notPart += ':not(:first)' unless collection.isTimeSeries()
      $tr.find("td#{notPart}").each (order) ->
        $td = $(@)
        $td.attr(key, value) for key, value of args
        $td.attr('monthId', order + 1) if collection.isTimeSeries()

  changeRow: (args, value, collection) =>
    selector = ''
    selector += "[#{field}=#{args[order]}]" for field, order in collection.schema
    $("table.#{collection.name} tbody tr td#{selector}:first").html(value)

    @renderForecasts()
