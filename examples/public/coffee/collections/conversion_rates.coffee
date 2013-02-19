BaseCollection = require('./shared/base_collection')

module.exports = class ConversionRates extends BaseCollection
  name: 'conversionRates'
  schema: ['notFirstStageId', 'channelId', 'monthId']
  multiplier: 100
