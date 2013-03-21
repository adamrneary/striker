# Reach              = require('striker/reach')
# Periods            = require('collections/periods')
# Channels           = require('collections/channels')
# Stages             = require('collections/stages')
# ConversionSummary  = require('collections/conversion_summary')
# ConversionForecast = require('collections/conversion_forecast')

# # Reach analysis striker
# # Reach (also called "Topline growth") is the conversion number for the topline
# # stage. It represents the total number of potential customers a company might
# # acquire. For a web company like ours, "reach" might include all potential
# # users that visit our website, whether they become paying customers or not.
# #
# # To calculate, we basically filter conversionSummary and conversionForecast to
# # the topline stage and group by channel and period.
# #
# #   actual   => an Integer from conversionSummary (null for future periods)
# #   plan     => an Integer from conversionForecast
# #   variance => an Integer (actual - plan) (null for future periods)
# describe 'reach', ->
#   beforeEach ->
#     app.periods = new Periods [
#       {id: 'last-month',    first_day: '2012-01-01'},
#       {id: 'this-month',    first_day: '2012-02-01'},
#       {id: 'next-month',    first_day: '2012-03-01'},
#       {id: 'two-years-ago', first_day: '2010-02-14'}
#     ]
#     app.channels = new Channels [
#       {id: 'channel1'}
#       {id: 'channel2'}
#     ]
#     app.stages   = new Stages [
#       {id: 'topline', position: 2}
#       {id: 'customer', position: 1}
#     ]
#     app.conversionSummary  = new ConversionSummary [
#       {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 1},
#       {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 2},
#       {period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 3},
#       {period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 4},
#       {period_id: 'this-month', stage_id: 'customer', channel_id: 'channel1', customer_volume: 5},
#     ]
#     app.conversionForecast = new ConversionForecast [
#       {period_id: 'last-month', channel_id: 'channel1', stage_id: 'topline', value: 6},
#       {period_id: 'last-month', channel_id: 'channel2', stage_id: 'topline', value: 7},
#       {period_id: 'this-month', channel_id: 'channel1', stage_id: 'topline', value: 8},
#       {period_id: 'this-month', channel_id: 'channel2', stage_id: 'topline', value: 9},
#       {period_id: 'next-month', channel_id: 'channel1', stage_id: 'topline', value: 10},
#       {period_id: 'next-month', channel_id: 'channel2', stage_id: 'topline', value: 11},
#       {period_id: 'this-month', channel_id: 'channel1', stage_id: 'customer', value: 12},
#     ]
#     stubCurrentDate '2012-02-14'

#   describe 'overall reach', ->
#     beforeEach ->
#       app.reach = new Reach()

#     describe 'get', ->
#       it 'calculates values for a single channel and period', ->
#         result = app.reach 'channel1', 'last-month'
#         expect(result['actual']).toEqual 1
#         expect(result['plan']).toEqual 6
#         expect(result['variance']).toEqual (1-6)

#       it 'contains no "actual" or "variance" for future months', ->
#         result = app.reach 'channel1', 'next-month'
#         expect(result['actual']).toBeUndefined
#         expect(result['plan']).toEqual 10
#         expect(result['variance']).toBeUndefined

#       it 'returns an array of objects (all periods) by default', ->
#         result = app.reach()
#         expect(_.isArray(result)).toBeTruthy()
#         expect(_.size(result)).toEqual 4
#         expect(result[0]['channelId']).toEqual 'channel1'
#         expect(result[0]['periodId']).toEqual 'last-month'
#         expect(result[0]['actual']).toEqual 1
#         expect(result[0]['plan']).toEqual 6
#         expect(result[0]['variance']).toEqual (1-6)

#     describe 'triggers', ->
#       it 'responds to changes in conversionSummary', ->
#         model = app.conversionSummary.findWhere(
#           {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'}
#         )
#         model.set(customer_volume: 2)

#         result = app.reach 'channel1', 'last-month'
#         expect(result['actual']).toEqual 2
#         expect(result['plan']).toEqual 6
#         expect(result['variance']).toEqual (2-6)

#       it 'responds to changes in conversionForecast', ->
#         model = app.conversionForecast.findWhere(
#           {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'}
#         )
#         model.set(value: 9)

#         result = app.reach 'channel1', 'last-month'
#         expect(result['actual']).toEqual 1
#         expect(result['plan']).toEqual 9
#         expect(result['variance']).toEqual (1-9)

#   describe 'channel reach', ->
#     beforeEach ->
#       @channel = app.channels.get('channel1')

#     describe 'get', ->
#       it 'calculates values for a single period', ->
#         result = @channel.reach 'last-month'
#         expect(result['actual']).toEqual 1
#         expect(result['plan']).toEqual 6
#         expect(result['variance']).toEqual (1-6)

#       it 'contains no "actuals" for a future month', ->
#         result = @channel.reach 'next-month'
#         expect(result['actual']).toBeUndefined
#         expect(result['plan']).toEqual 10
#         expect(result['variance']).toBeUndefined

#       it 'returns an array of objects (all periods) by default', ->
#         result = @channel.reach()
#         expect(_.isArray(result)).toBeTruthy()
#         expect(_.size(result)).toEqual 4
#         expect(result[0]['periodId']).toEqual 'last-month'
#         expect(result[0]['actual']).toEqual 1
#         expect(result[0]['plan']).toEqual 6
#         expect(result[0]['variance']).toEqual (1-6)

#     describe 'triggers', ->
#       it 'responds to changes in conversionSummary', ->
#         model = app.conversionSummary.findWhere(
#           {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'}
#         )
#         model.set(customer_volume: 2)

#         result = @channel.reach 'last-month'
#         expect(result['actual']).toEqual 2
#         expect(result['plan']).toEqual 6
#         expect(result['variance']).toEqual (2-6)

#       it 'responds to changes in conversionForecast', ->
#         model = app.conversionForecast.findWhere(
#           {period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'}
#         )
#         model.set(value: 9)

#         result = @channel.reach 'last-month'
#         expect(result['actual']).toEqual 1
#         expect(result['plan']).toEqual 9
#         expect(result['variance']).toEqual (1-9)
