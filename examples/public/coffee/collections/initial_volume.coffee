BaseCollection = require('./shared/base_collection')

module.exports = class InitialVolume extends BaseCollection
  name: 'initialVolume'
  schema: ['stageId', 'channelId', 'segmentId']
