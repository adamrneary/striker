Collection = require('lib/collection')

module.exports = class ConversionForecast extends Collection
  url: 'api/v1/conversion_forecast'

  getValue: ->
    (item) -> plan: item.value
