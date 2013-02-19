BaseCollection = require('./shared/base_collection')

module.exports = class ChurnRates extends BaseCollection
  name: 'churnRates'
  schema: ['segmentId', 'monthId']
  multiplier: 100
