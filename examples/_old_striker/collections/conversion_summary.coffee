Collection = require('lib/collection')

module.exports = class ConversionSummary extends Collection
  url: 'api/v1/conversion_summary'

  getValue: ->
    (item) -> actual: item.customer_volume
