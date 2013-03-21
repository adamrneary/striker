module.exports = class ChannelSegmentMix extends Striker.Collection
  calc: (periodId) ->
    [key1, key2]  = switch @constructor.name
      when 'Channel' then ['channel_id', 'segment_id']
      when 'Segment' then ['segment_id', 'channel_id']
    filterObject = {}
    filterObject[key1] = @id

    collectionIds = ChannelSegmentMix::getBySchema(key2)
    result        = {}
    revenue       = app.customers.revenue(periodId)
    customers     = app.customers.where(filterObject)
    channelSM     = app.channelSegmentMix.where(_.extend period_id: periodId, filterObject)
    totalRevenue  = Striker.utils.sum(revenue?[customer.id]?.actual for customer in customers)

    for key2Id in collectionIds
      customerId    = _.find(customers, (item) -> item.get(key2) is key2Id)?.id
      distribution  = _.find(channelSM, (item) -> item.get(key2) is key2Id)?.get('distribution')
      revenueForKey = revenue?[customerId].actual

      result[key2Id] = {}
      result[key2Id].actual = revenueForKey / totalRevenue if revenueForKey && totalRevenue
      result[key2Id].plan   = distribution
    result
