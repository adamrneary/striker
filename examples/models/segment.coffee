Model = require('lib/model')

module.exports = class Segment extends Model
  @hasAnalyse 'channelMix', file: 'channel_segment_mix'
  @hasAnalyse 'churnRate',
  @hasAnalyse 'churnedCustomers',
  @hasAnalyse 'customerVolume',
  @hasAnalyse 'newCustomers',

  @hasAnalyse 'newCustomerCount', plan: (periodId) ->
    newCustomers = app.channels.newCustomers(periodId)
    result = for channelId, values of @channelMix(periodId)
      values.plan * newCustomers[channelId].plan
    Math.round Striker.utils.sum(result)

  @hasAnalyse 'churn', plan: (periodId) ->
    prevPeriodId   = app.periods.prevId(periodId)
    customerVolume = Striker.utils.specialCondition @customerVolume(prevPeriodId)
    churnRate      = @churnRate(periodId)?.plan

    Math.round(churnRate * customerVolume)

  @hasAnalyse 'revenue', actualMap: {from: 'customer_id', to: 'segment_id'}, plan: (periodId) ->
    @customerVolume(periodId).plan * @unitRevenue(periodId).plan  initialize: () ->

  initialize: ->
    @name = "Segment"

  customers: ->
    app.customers.where(segment_id: @id)

  # Stubs
  unitRevenue: (periodId) ->
  customersRevenue: (periodId) ->
