NewCustomers      = require('striker/new_customers')
Periods           = require('collections/periods')
Customers         = require('collections/customers')
Channels          = require('collections/channels')
Segments          = require('collections/segments')

# "new customers" is an array of customer ids who began paying that period.
#   A "new customer" is a customer who had not paid the previous period but
#   paid this period. while we forecast overall new customers in other metrics,
#   we don't forecast specific new customers (obviously? they're new!)
#
# if there is no prior period, all paying customers are considered new
describe 'new customers', ->
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
          customer6: {actual: 0}
        when 'this-month'
          customer1: {actual: 400}
          customer2: {actual: 500}
          customer3: {actual: 500}
          customer4: {actual: 0}
          customer5: {actual: 0}
          customer6: {actual: 2923}

  # default new customers are all new customers for the company that period
  #   with no other filters.
  describe 'default new customers', ->
    beforeEach ->
      @newCustomers = new NewCustomers()

    describe 'get', ->
      it 'returns an array of customer ids', ->
        expect(@newCustomers.get 'last-month').toEqual ['customer1', 'customer3','customer4']
        expect(@newCustomers.get 'this-month').toEqual ['customer2', 'customer6']

      it 'returns an array with period ids', ->
        result = @newCustomers.get ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # segment new customers are filtered to customers in that segment
  describe 'segment new customers', ->
    beforeEach ->
      @segment = app.segments.get('segment1')

    describe 'get', ->
      it 'returns an array of customer ids', ->
        expect(@segment.newCustomers 'last-month').toEqual ['customer1', 'customer4']
        expect(@segment.newCustomers 'this-month').toEqual ['customer2']

      it 'returns an array with period ids', ->
        result = @segment.newCustomers ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # channel new customers are filtered to customers in that channel
  describe 'channel new customers', ->
    beforeEach ->
      @channel = app.channels.get('channel2')

    describe 'get', ->
      it 'returns an array of customer ids', ->
        expect(@channel.newCustomers 'last-month').toEqual ['customer3']
        expect(@channel.newCustomers 'this-month').toEqual ['customer6']

      it 'returns an array with period ids', ->
        result = @channel.newCustomers ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3
