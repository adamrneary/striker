Collection = require('lib/collection')
Segment   = require('models/segment')

module.exports = class Segments extends Collection
  url: 'api/v1/segments'
  model: Segment

  # Stub for revenue
  revenue: (periodId) ->
  churn: (periodId) ->
