class IndexView extends Backbone.View
  el: '#container'

  initialize: ->
    $('li.example').addClass('active')

  render: =>
    @renderInputs()
    @renderForecasts()
    @highlight()
    @

  renderInputs: ->
    for input in [app.streams, app.segments, app.channels, app.stages, app.channelSegmentMix,\
                  app.initialVolume, app.toplineGrowth, app.conversionRates, app.churnRates]
      @renderCollection(input)
      @makeInteractive(input) if input.schema

  renderForecasts: ->
    for forecast in [app.conversionForecast, app.churnForecast, app.customerForecast]
      @renderCollection(forecast)

    new HighChart().render()

  highlight: ->
    $('''
      .channelSegmentMix td:last-child,
      .initialVolume td:last-child,
      .toplineGrowth td:not(:first-child),
      .conversionRates td:not(:first-child, :nth-child(2)),
      .churnRates td:not(:first-child)
    ''').addClass('yellow')

  renderCollection: (collection) ->
    @$(".#{collection.name} tbody").html('')
    for line in collection.print()
      row = new Row(collection: line)
      @$(".#{collection.name} tbody").append row.render().el

  makeInteractive: (collection) ->
    collection.on('change', @changeRow)
    dopSelector = if collection.isMonth() then ':not(:first)' else ''

    $(".#{collection.name} tr:not(:first)#{dopSelector}").each ->
      [$tr, args, notPart] = [$(@), {}, '']

      for field, order in collection.schema
        notPart += ':not(:first)' if order > 0
        args[field] = $tr.find("td#{notPart}:first").html()

      notPart += ':not(:first)' unless collection.isMonth()
      $tr.find("td#{notPart}").each (order) ->
        $td = $(@)
        $td.attr(key, value) for key, value of args
        $td.attr('monthId', order + 1) if collection.isMonth()

  changeRow: (args, value, collection) =>
    selector = ''
    selector += "[#{field}=#{args[order]}]" for field, order in collection.schema
    $("table.#{collection.name} tbody tr td#{selector}:first").html(value)

    @renderForecasts()
