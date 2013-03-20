# NewCustomerCount    = require('striker/new_customer_count')
# NewCustomers        = require('striker/new_customers')
# Periods             = require('collections/periods')
# Channels            = require('collections/channels')
# Segments            = require('collections/segments')
# Stages              = require('collections/stages')
# ConversionForecast  = require('collections/conversion_forecast')
#
# describe 'new customer count', ->
#   beforeEach ->
#     stubCurrentDate '2012-02-14'
#     app.periods  = new Periods [
#       {id: 'last-month',      first_day: '2012-01-01'},
#       {id: 'this-month',      first_day: '2012-02-01'},
#       {id: 'next-month',      first_day: '2012-03-01'},
#       {id: 'following-month', first_day: '2012-04-01'},
#       {id: 'two-years-ago',   first_day: '2010-02-01'}
#     ]
#     app.channels  = new Channels [
#       {id: 'channel1'},
#       {id: 'channel2'}
#     ]
#     app.segments  = new Segments [
#       {id: 'segment1'},
#       {id: 'segment2'}
#     ]
#     app.stages    = new Stages [
#       {id: 'prospect', position: 3},
#       {id: 'lead',     position: 2},
#       {id: 'customer', position: 1},
#     ]
#     app.conversionForecast = new ConversionForecast [
#       {period_id: 'last-month', stage_id: 'prospect', channel_id: 'channel1', conversion_forecast: 120},
#       {period_id: 'last-month', stage_id: 'prospect', channel_id: 'channel2', conversion_forecast: 130},
#       {period_id: 'last-month', stage_id: 'lead',     channel_id: 'channel1', conversion_forecast: 140},
#       {period_id: 'last-month', stage_id: 'lead',     channel_id: 'channel2', conversion_forecast: 150},
#       {period_id: 'last-month', stage_id: 'customer', channel_id: 'channel1', conversion_forecast: 160},
#       {period_id: 'last-month', stage_id: 'customer', channel_id: 'channel2', conversion_forecast: 170},
#       {period_id: 'this-month', stage_id: 'prospect', channel_id: 'channel1', conversion_forecast: 180},
#       {period_id: 'this-month', stage_id: 'prospect', channel_id: 'channel2', conversion_forecast: 190},
#       {period_id: 'this-month', stage_id: 'lead',     channel_id: 'channel1', conversion_forecast: 200},
#       {period_id: 'this-month', stage_id: 'lead',     channel_id: 'channel2', conversion_forecast: 210},
#       {period_id: 'this-month', stage_id: 'customer', channel_id: 'channel1', conversion_forecast: 220},
#       {period_id: 'this-month', stage_id: 'customer', channel_id: 'channel2', conversion_forecast: 230},
#       {period_id: 'next-month', stage_id: 'prospect', channel_id: 'channel1', conversion_forecast: 240},
#       {period_id: 'next-month', stage_id: 'prospect', channel_id: 'channel2', conversion_forecast: 250},
#       {period_id: 'next-month', stage_id: 'lead',     channel_id: 'channel1', conversion_forecast: 260},
#       {period_id: 'next-month', stage_id: 'lead',     channel_id: 'channel2', conversion_forecast: 270},
#       {period_id: 'next-month', stage_id: 'customer', channel_id: 'channel1', conversion_forecast: 280},
#       {period_id: 'next-month', stage_id: 'customer', channel_id: 'channel2', conversion_forecast: 290}
#     ]
#     app.newCustomers = new NewCustomers()
#
#   # default new customer count is:
#   #   actual => distinct count of new customers in the period
#   #   plan   => sum of ConversionForecast for customer stage
#   describe 'default new customer count', ->
#     beforeEach ->
#       spyOn(NewCustomers::, 'get').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month' then ['customer1', 'customer2']
#           when 'this-month' then ['customer3']
#
#       @newCustomerCount = new NewCustomerCount()
#
#     describe 'get', ->
#       it 'returns an actual/plan object', ->
#         expect(@newCustomerCount.get 'last-month').toEqual actual: 2, plan: 160+170
#         expect(@newCustomerCount.get 'this-month').toEqual actual: 1, plan: 220+230
#         expect(@newCustomerCount.get 'next-month').toEqual            plan: 280+290
#
#       it 'returns an array with period ids', ->
#         result = @newCustomerCount.get ['last-month', 'this-month', 'next-month']
#         expect(_.keys(result).length).toEqual 3
#
#   # channel new customer count is:
#   #   actual => distinct count of channel new customers in the period
#   #   plan   => sum of ConversionForecast for that channel for customer stage
#   describe 'channel new customer count', ->
#     beforeEach ->
#       @channel = app.channels.get('channel1')
#       spyOn(@channel, 'newCustomers').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month' then ['customer1', 'customer2', 'customer3']
#           when 'this-month' then ['customer3']
#
#     describe 'get', ->
#       it 'returns an actual/plan object', ->
#         expect(@channel.newCustomerCount 'last-month').toEqual actual: 3, plan: 160
#         expect(@channel.newCustomerCount 'this-month').toEqual actual: 1, plan: 220
#         expect(@channel.newCustomerCount 'next-month').toEqual            plan: 280
#
#       it 'returns an array with period ids', ->
#         result = @channel.newCustomerCount ['last-month', 'this-month', 'next-month']
#         expect(_.keys(result).length).toEqual 3
#
#   # segment new customer count is:
#   #   actual => distinct count of segment new customers in the period
#   #   plan   => sum of:
#   #               for each channel in a segment's channel mix,
#   #                 channel new customer count (plan)
#   #               * that segment's mix (%)
#   #             note: new customers should be rounded to an integer, which may
#   #               introduce a potential rounding error for plan...known issue.
#   describe 'segment churn', ->
#     beforeEach ->
#       @segment = app.segments.get('segment1')
#       spyOn(@segment, 'newCustomers').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month' then ['customer1', 'customer2', 'customer3']
#           when 'this-month' then ['customer4', 'customer5']
#
#       spyOn(@segment, 'channelMix').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'
#             channel1: {actual: 0.3, plan: 0.35}
#             channel2: {actual: 0.2, plan: 0.23}
#           when 'this-month'
#             channel1: {actual: 0.4, plan: 0.45}
#             channel2: {actual: 0.3, plan: 0.33}
#           when 'next-month'
#             channel1: {             plan: 0.55}
#             channel2: {             plan: 0.43}
#
#       spyOn(app.channels, 'newCustomers').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'
#             channel1: {actual: 1, plan: 10}
#             channel2: {actual: 3, plan: 40}
#           when 'this-month'
#             channel1: {actual: 2, plan: 20}
#             channel2: {actual: 4, plan: 50}
#           when 'next-month'
#             channel1: {             plan: 30}
#             channel2: {             plan: 60}
#
#     describe 'get', ->
#       it 'returns an actual/plan object', ->
#         expect(@segment.newCustomerCount 'last-month').toEqual actual: 3, plan: Math.round(0.35 * 10 + 0.23 * 40)
#         expect(@segment.newCustomerCount 'this-month').toEqual actual: 2, plan: Math.round(0.45 * 20 + 0.33 * 50)
#         expect(@segment.newCustomerCount 'next-month').toEqual            plan: Math.round(0.55 * 30 + 0.43 * 60)
#
#       it 'returns an array with period ids', ->
#         result = @segment.newCustomerCount ['last-month', 'this-month', 'next-month']
#         expect(_.keys(result).length).toEqual 3
