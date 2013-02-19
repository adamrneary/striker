module.exports = class HighChart extends Backbone.View
  render: ->
    chart = new Highcharts.Chart
      chart:
        renderTo: 'highchart'
        type: 'line'
        marginRight: 230
        marginBottom: 25
      title:
        text: 'Forecasts'
      xAxis:
        categories: admin.months.pluck('id')
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
      series: [{
        name: 'Conversion forecast'
        data: @average(admin.conversionForecast)
      },{
        name: 'Churned customer forecast'
        data: @average(admin.churnForecast)
      },{
        name: 'Customer volume forecast'
        data: @average(admin.customerForecast)
      }]

  average: (collection) ->
    result = _.range(1, 37)
    print  = collection.print()

    for row in print
      values = row.slice admin.conversionForecast.schema.length - 1
      result[order] += value for value, order in values

    for sum, order in result
      result[order] = parseFloat (result[order]/print.length).toFixed(2)

    result

