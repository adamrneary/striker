# CustomerVolume   = require('striker/customer_volume')
# NewCustomerCount = require('striker/new_customer_count')
# Churn            = require('striker/churn')
# Periods          = require('collections/periods')
# Channels         = require('collections/channels')
# Segments         = require('collections/segments')
#
# describe 'customer volume', ->
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
#
#   # default customer volume is:
#   #   actual => distinct count of customers with revenue > 0 in the period
#   #   plan   =>   previous period customer volume
#   #             + current period planned new customers
#   #             - current period planned churn
#   #             note for previous period customer volume:
#   #               if no previous period exists, use 0
#   #                 if actuals exist for previous period, use actuals
#   #                 else use plan
#   describe 'default customer volume', ->
#     beforeEach ->
#       spyOn(app.customers, 'revenue').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'
#             customer1: {actual: 10}
#             customer2: {actual: 20}
#             customer3: {actual: 0}
#           when 'this-month'
#             customer1: {actual: 20}
#             customer2: {actual: 30}
#             customer3: {actual: 40}
#             customer4: {actual: 40}
#
#       spyOn(NewCustomerCount::, 'get').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'       then actual: 50,  plan: 60
#           when 'this-month'       then actual: 70,  plan: 80
#           when 'next-month'       then              plan: 100
#           when 'following-month'  then              plan: 120
#
#       spyOn(Churn::, 'get').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'       then actual: 5,   plan: 6
#           when 'this-month'       then actual: 7,   plan: 8
#           when 'next-month'       then              plan: 10
#           when 'following-month'  then              plan: 12
#
#       app.newCustomerCount = new NewCustomerCount()
#       app.churn            = new Churn()
#       @customerVolume      = new CustomerVolume()
#
#     describe 'get', ->
#       it 'returns an actual/plan object', ->
#         expect(@customerVolume.get 'last-month').toEqual actual: 2, plan: 60-6
#         expect(@customerVolume.get 'this-month').toEqual actual: 4, plan: 2+80-8
#         expect(@customerVolume.get 'next-month').toEqual            plan: 4+100-10
#         expect(@customerVolume.get 'following-month').toEqual       plan: (4+100-10)+120-12
#
#       it 'returns an array with period ids', ->
#         result = @customerVolume.get ['last-month', 'this-month', 'next-month']
#         expect(_.keys(result).length).toEqual 3
#
#   # channel customer volume is:
#   #   actual => distinct count of channel customers with revenue > 0 in the period
#   #   plan   => (see default customer volume)
#   describe 'channel customer volume', ->
#     beforeEach ->
#       @channel = app.channels.get('channel1')
#       spyOn(@channel, 'customersRevenue').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'
#             customer1: {actual: 10}
#             customer2: {actual: 20}
#             customer3: {actual: 0}
#           when 'this-month'
#             customer1: {actual: 20}
#             customer2: {actual: 30}
#             customer3: {actual: 40}
#             customer4: {actual: 40}
#       spyOn(@channel, 'newCustomerCount').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'       then actual: 50,  plan: 60
#           when 'this-month'       then actual: 70,  plan: 80
#           when 'next-month'       then              plan: 100
#           when 'following-month'  then              plan: 120
#       spyOn(@channel, 'churn').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'       then actual: 5,  plan: 6
#           when 'this-month'       then actual: 7,  plan: 8
#           when 'next-month'       then             plan: 10
#           when 'following-month'  then             plan: 12
#
#     describe 'get', ->
#       it 'returns an actual/plan object', ->
#         expect(@channel.customerVolume 'last-month').toEqual actual: 2, plan: 60-6
#         expect(@channel.customerVolume 'this-month').toEqual actual: 4, plan: 2+80-8
#         expect(@channel.customerVolume 'next-month').toEqual            plan: 4+100-10
#         expect(@channel.customerVolume 'following-month').toEqual       plan: (4+100-10)+120-12
#
#       it 'returns an array with period ids', ->
#         result = @channel.customerVolume ['last-month', 'this-month', 'next-month']
#         expect(_.keys(result).length).toEqual 3
#
#   # segment customer volume is:
#   #   actual => distinct count of segment customers with revenue > 0 in the period
#   #   plan   => (see default customer volume)
#   describe 'segment customer volume', ->
#     beforeEach ->
#       @segment = app.segments.get('segment1')
#       spyOn(@segment, 'customersRevenue').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'
#             customer1: {actual: 10}
#             customer2: {actual: 20}
#             customer3: {actual: 0}
#           when 'this-month'
#             customer1: {actual: 20}
#             customer2: {actual: 30}
#             customer3: {actual: 40}
#             customer4: {actual: 40}
#       spyOn(@segment, 'newCustomerCount').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'       then actual: 50,  plan: 60
#           when 'this-month'       then actual: 70,  plan: 80
#           when 'next-month'       then              plan: 100
#           when 'following-month'  then              plan: 120
#       spyOn(@segment, 'churn').andCallFake (periodId) ->
#         switch periodId
#           when 'last-month'       then actual: 5,   plan: 6
#           when 'this-month'       then actual: 7,   plan: 8
#           when 'next-month'       then              plan: 10
#           when 'following-month'  then              plan: 12
#
#     describe 'get', ->
#       it 'returns an actual/plan object', ->
#         expect(@segment.customerVolume 'last-month').toEqual actual: 2, plan: 60-6
#         expect(@segment.customerVolume 'this-month').toEqual actual: 4, plan: 2+80-8
#         expect(@segment.customerVolume 'next-month').toEqual plan: 4+100-10
#         expect(@segment.customerVolume 'following-month').toEqual plan: (4+100-10)+120-12
#
#       it 'returns an array with period ids', ->
#         result = @segment.customerVolume ['last-month', 'this-month', 'next-month']
#         expect(_.keys(result).length).toEqual 3
