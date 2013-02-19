BaseCollection = require('./shared/base_collection')

module.exports = class ChannelSegmentMix extends BaseCollection
  name: 'channelSegmentMix'
  schema: ['channelId', 'segmentId']
  multiplier: 100
