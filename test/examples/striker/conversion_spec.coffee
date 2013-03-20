# Conversion         = require('striker/conversion')
# NewCustomers       = require('striker/new_customers')
# Periods            = require('collections/periods')
# Channels           = require('collections/channels')
# Stages             = require('collections/stages')
# ConversionSummary  = require('collections/conversion_summary')
# ConversionForecast = require('collections/conversion_forecast')
#
# describe 'conversion', ->
#   beforeEach ->
#     stubCurrentDate '2012-02-14'
#     app.periods  = new Periods [
#       {id: 'last-month',    first_day: '2012-01-01'},
#       {id: 'this-month',    first_day: '2012-02-01'},
#       {id: 'next-month',    first_day: '2012-03-01'},
#       {id: 'two-years-ago', first_day: '2010-02-14'}
#     ]
#     app.channels = new Channels [{id: 'channel1'}, {id: 'channel2'}]
#     app.stages   = new Stages [
#       {id: 'prospect',  position: 3, lag_periods: 2},
#       {id: 'lead',      position: 2},
#       {id: 'customer',  position: 1}
#     ]
#     app.newCustomers = new NewCustomers()
#     app.conversionSummary  = new ConversionSummary [
#       {period_id: 'last-month', stage_id: 'prospect', channel_id: 'channel1', customer_volume: 10},
#       {period_id: 'last-month', stage_id: 'prospect', channel_id: 'channel2', customer_volume: 20},
#       {period_id: 'last-month', stage_id: 'lead',     channel_id: 'channel1', customer_volume: 30},
#       {period_id: 'last-month', stage_id: 'lead',     channel_id: 'channel2', customer_volume: 40},
#       {period_id: 'this-month', stage_id: 'prospect', channel_id: 'channel1', customer_volume: 50},
#       {period_id: 'this-month', stage_id: 'prospect', channel_id: 'channel2', customer_volume: 60},
#       {period_id: 'this-month', stage_id: 'lead',     channel_id: 'channel1', customer_volume: 70},
#       {period_id: 'this-month', stage_id: 'lead',     channel_id: 'channel2', customer_volume: 80}
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
#
#   # default conversion is the number of new potential customers at each stage
#   #   in the customer acquisition cycle.
#   #
#   # - we have plan data for all stages
#   # - we have actual data for all stages except the customer stage
#   #   for the customer stage, we use the size of the NewCustomers array
#   describe 'default conversion', ->
#     beforeEach ->
#       spyOn(NewCustomers::, 'get').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month' then ['customer1', 'customer2']
#           when 'this-month' then ['customer3']
#
#       @analysis = new Conversion()
#
#     describe 'get', ->
#       it 'contains all stages', ->
#         result = @analysis.get('this-month')
#         expect(_.keys(result).length).toEqual 3
#
#       it 'calculates values for a single stage', ->
#         result = @analysis.get('last-month')
#         expect(result['prospect']).toEqual actual: 30, plan: 250
#         expect(result['lead']).toEqual     actual: 70, plan: 290
#         expect(result['customer']).toEqual actual: 2,  plan: 330
#
#       it 'contains no "actuals" for a future month', ->
#         result = @analysis.get('next-month')
#         expect(result['prospect']).toEqual plan: 490
#         expect(result['lead']).toEqual     plan: 530
#         expect(result['customer']).toEqual plan: 570
#
#       it 'contains object grouped by period and stage', ->
#         result = @analysis.get ['last-month', 'this-month', 'next-month']
#         expect(result['this-month']['prospect']).toEqual actual: 110, plan: 370
#         expect(result['this-month']['lead']).toEqual     actual: 150, plan: 410
#         expect(result['this-month']['customer']).toEqual actual: 1, plan: 450
#
#   # channel conversion is the number of new potential customers at each stage
#   #   in the customer acquisition cycle in that channel
#   #
#   # - we have plan data for all stages
#   # - we have actual data for all stages except the customer stage
#   #   for the customer stage, we use the size of the NewCustomers array
#   describe 'channel conversion', ->
#     beforeEach ->
#       @channel = app.channels.get('channel1')
#       spyOn(@channel, 'newCustomers').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month' then ['customer1', 'customer2', 'customer4']
#           when 'this-month' then ['customer3']
#
#     describe 'get', ->
#       it 'contains all stages', ->
#         result = @channel.conversion('this-month')
#         expect(_.keys(result).length).toEqual 3
#
#       it 'calculates values for a single stage', ->
#         result = @channel.conversion('last-month')
#         expect(result['prospect']).toEqual actual: 10, plan: 120
#         expect(result['lead']).toEqual     actual: 30, plan: 140
#         expect(result['customer']).toEqual actual: 3,  plan: 160
#
#       it 'contains no "actuals" for a future month', ->
#         result = @channel.conversion('next-month')
#         expect(result['prospect']).toEqual plan: 240
#         expect(result['lead']).toEqual     plan: 260
#         expect(result['customer']).toEqual plan: 280
#
#       it 'contains object grouped by period and stage', ->
#         result = @channel.conversion ['last-month', 'this-month', 'next-month']
#         expect(result['this-month']['prospect']).toEqual actual: 50, plan: 180
#         expect(result['this-month']['lead']).toEqual     actual: 70, plan: 200
#         expect(result['this-month']['customer']).toEqual actual: 1,  plan: 220
