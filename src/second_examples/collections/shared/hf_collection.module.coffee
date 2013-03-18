# Base class for History/Forceast collections
Collection  = require('collections/shared/collection')

module.exports = class HFCollection extends Collection
  minify: ->
    @map (item) -> item.attributes

  getValue: ->
    attr = switch @constructor.name
      when 'ConversionSummary'  then (item) -> actual: item.customer_volume
      when 'ConversionForecast' then (item) -> plan:   item.value
      when 'FinancialSummary'   then (item) -> actual: item.amount_cents
