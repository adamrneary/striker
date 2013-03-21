ChurnRate      = require('striker/churn_rate')
Churn          = require('striker/churn')
CustomerVolume = require('striker/customer_volume')
Periods        = require('collections/periods')
Channels       = require('collections/channels')
Segments       = require('collections/segments')

# churnRate(period n) = churn(period n) / customerVolume(period n-1)
#   for both actual and plan
# where period n-1 does not exist, return null
# where period n-1 has actual, plan churn should use actuals for customerVolume
describe 'churn rate', ->
  beforeEach ->
    stubCurrentDate '2012-02-14'
    app.periods  = new Periods [
      {id: 'last-month',      first_day: '2012-01-01'},
      {id: 'this-month',      first_day: '2012-02-01'},
      {id: 'next-month',      first_day: '2012-03-01'},
      {id: 'following-month', first_day: '2012-04-01'},
      {id: 'two-years-ago',   first_day: '2010-02-01'}
    ]
    app.channels  = new Channels [
      {id: 'channel1'},
      {id: 'channel2'}
    ]
    app.segments  = new Segments [
      {id: 'segment1'},
      {id: 'segment2'}
    ]

  # default churn rate is the churn rate for the entire company
  describe 'default churn rate', ->
    beforeEach ->
      spyOn(Churn::, 'get').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 1,   plan: 3
          when 'this-month'       then actual: 2,   plan: 4
          when 'next-month'       then              plan: 5
          when 'following-month'  then              plan: 6
      spyOn(CustomerVolume::, 'get').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 10,  plan: 36
          when 'this-month'       then actual: 25,  plan: 54
          when 'next-month'       then              plan: 59
          when 'following-month'  then              plan: 69

      app.churn          = new Churn()
      app.customerVolume = new CustomerVolume()
      @churnRate         = new ChurnRate()

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@churnRate.get 'last-month').toEqual actual: null,   plan: null
        expect(@churnRate.get 'this-month').toEqual actual: (2/10), plan: (4/10)
        expect(@churnRate.get 'next-month').toEqual                 plan: (5/25)
        expect(@churnRate.get 'following-month').toEqual            plan: (6/59)

      it 'returns an array with period ids', ->
        result = @churnRate.get ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # segment churn rate is filtered to the specific segment
  describe 'segment churn rate', ->
    beforeEach ->
      @segment = app.segments.get('segment1')
      spyOn(@segment, 'churn').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 1,   plan: 3
          when 'this-month'       then actual: 2,   plan: 4
          when 'next-month'       then              plan: 5
          when 'following-month'  then              plan: 6
      spyOn(@segment, 'customerVolume').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 10,  plan: 36
          when 'this-month'       then actual: 25,  plan: 54
          when 'next-month'       then              plan: 59
          when 'following-month'  then              plan: 69

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@segment.churnRate 'last-month').toEqual actual: null,   plan: null
        expect(@segment.churnRate 'this-month').toEqual actual: (2/10), plan: (4/10)
        expect(@segment.churnRate 'next-month').toEqual                 plan: (5/25)
        expect(@segment.churnRate 'following-month').toEqual            plan: (6/59)

      it 'returns an array with period ids', ->
        result = @segment.churnRate ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # channel churn rate is filtered to the specific channel
  describe 'channel churn rate', ->
    beforeEach ->
      @channel = app.channels.get('channel1')
      spyOn(@channel, 'churn').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 1,   plan: 3
          when 'this-month'       then actual: 2,   plan: 4
          when 'next-month'       then              plan: 5
          when 'following-month'  then              plan: 6
      spyOn(@channel, 'customerVolume').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 10,  plan: 36
          when 'this-month'       then actual: 25,  plan: 54
          when 'next-month'       then              plan: 59
          when 'following-month'  then              plan: 69

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@channel.churnRate 'last-month').toEqual actual: null,   plan: null
        expect(@channel.churnRate 'this-month').toEqual actual: (2/10), plan: (4/10)
        expect(@channel.churnRate 'next-month').toEqual                 plan: (5/25)
        expect(@channel.churnRate 'following-month').toEqual            plan: (6/59)

      it 'returns an array with period ids', ->
        result = @channel.churnRate ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3
