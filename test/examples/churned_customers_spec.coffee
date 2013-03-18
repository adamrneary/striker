ChurnedCustomers  = require('striker/churned_customers')
Periods           = require('collections/periods')
Customers         = require('collections/customers')
Channels          = require('collections/channels')
Segments          = require('collections/segments')

# churned customers is an array of customer ids who churned that period.
#   A "churn customer" is a customer who paid the previous period but did not
#   not pay this period. while we forecast overall churn in other metrics, we
#   don't forecast the churn of specific customers.
#
# if there is no prior period, an empty array is returned
describe 'churned customers', ->
  beforeEach ->
    stubCurrentDate '2012-02-14'
    app.periods  = new Periods [
      {id: 'last-month',      first_day: '2012-01-01'},
      {id: 'this-month',      first_day: '2012-02-01'},
      {id: 'next-month',      first_day: '2012-03-01'}
    ]
    app.customers = new Customers [
      {id: 'customer1', channel_id: 'channel1', segment_id: 'segment1'},
      {id: 'customer2', channel_id: 'channel1', segment_id: 'segment1'},
      {id: 'customer3', channel_id: 'channel2', segment_id: 'segment2'},
      {id: 'customer4', channel_id: 'channel1', segment_id: 'segment1'},
      {id: 'customer5', channel_id: 'channel2', segment_id: 'segment2'},
      {id: 'customer6', channel_id: 'channel2', segment_id: 'segment2'}
    ]
    app.channels  = new Channels [
      {id: 'channel1'},
      {id: 'channel2'}
    ]
    app.segments  = new Segments [
      {id: 'segment1'},
      {id: 'segment2'}
    ]
    spyOn(app.customers, 'revenue').andCallFake (periodId) ->
      switch periodId
        when 'last-month'
          customer1: {actual: 400}
          customer2: {actual: -1}
          customer3: {actual: 500}
          customer4: {actual: 3}
          customer5: {actual: 0}
          customer6: {actual: 2923}
        when 'this-month'
          customer1: {actual: 0}
          customer2: {actual: 500}
          customer3: {actual: 500}
          customer4: {actual: 0}
          customer5: {actual: 0}
          customer6: {actual: 0}

  # default churned customers are all churned customers for the company that
  #   period with no other filters.
  describe 'default churned customers', ->
    beforeEach ->
      @churnedCustomers = new ChurnedCustomers()

    describe 'get', ->
      it 'returns an array of customer ids', ->
        expect(@churnedCustomers.get 'last-month').toEqual []
        expect(@churnedCustomers.get 'this-month').toEqual ['customer1', 'customer4', 'customer6']

      it 'returns an array with period ids', ->
        result = @churnedCustomers.get ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # segment churned customers are filtered to customers in that segment
  describe 'segment churn', ->
    beforeEach ->
      @segment = app.segments.get('segment1')

    describe 'get', ->
      it 'returns an array of customer ids', ->
        expect(@segment.churnedCustomers 'last-month').toEqual []
        expect(@segment.churnedCustomers 'this-month').toEqual ['customer1', 'customer4']

      it 'returns an array with period ids', ->
        result = @segment.churnedCustomers ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # channel churned customers are filtered to customers in that channel
  describe 'channel churn', ->
    beforeEach ->
      @channel = app.channels.get('channel2')

    describe 'get', ->
      it 'returns an array of customer ids', ->
        expect(@channel.churnedCustomers 'last-month').toEqual []
        expect(@channel.churnedCustomers 'this-month').toEqual ['customer6']

      it 'returns an array with period ids', ->
        result = @channel.churnedCustomers ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3
