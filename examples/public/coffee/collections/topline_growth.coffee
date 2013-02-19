BaseCollection = require('./shared/base_collection')

module.exports = class ToplineGrowth extends BaseCollection
  name: 'toplineGrowth'
  schema: ['channelId', 'monthId']
