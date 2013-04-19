module.exports = class HighChart extends Backbone.View
  render: ->
    series = [{
      name: 'Conversion forecast'
      data: @average(app.conversionForecast)
    },{
      name: 'Churned customer forecast'
      data: @average(app.churnForecast)
    },{
      name: 'Customer volume forecast'
      data: @average(app.customerForecast)
    }]
    chart = new Highcharts.Chart
      chart:
        renderTo: 'highchart'
        type: 'line'
        marginRight: 230
        marginBottom: 25
      title:
        text: 'Forecasts'
      xAxis:
        categories: app.months.pluck('id')
      yAxis:
        title:
          text: 'Value'
      tooltip:
        formatter: ->
          "<b>#{@series.name}</b><br/>#{@x}: #{@y}"
      legend:
        layout: 'vertical'
        align: 'right'
        verticalAlign: 'top'
        x: -10
        y: 100
        borderWidth: 0
      series: series

  average: (collection) ->
    result = _.range(1, 37)
    print  = collection.print()

    for row in print
      values = row.slice app.conversionForecast.schema.length - 1
      result[order] += value for value, order in values

    for sum, order in result
      result[order] = parseFloat (result[order]/print.length).toFixed(2)

    result

