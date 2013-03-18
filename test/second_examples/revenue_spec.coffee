Revenue          = require('striker/revenue')
Accounts         = require('collections/accounts')
Periods          = require('collections/periods')
Customers        = require('collections/customers')
Channels         = require('collections/channels')
Segments         = require('collections/segments')
FinancialSummary = require('collections/financial_summary')

describe 'revenue', ->
  beforeEach ->
    stubCurrentDate '2012-02-14'
    app.periods  = new Periods [
      {id: 'last-month',    first_day: '2012-01-01'},
      {id: 'this-month',    first_day: '2012-02-01'},
      {id: 'next-month',    first_day: '2012-03-01'},
      {id: 'two-years-ago', first_day: '2010-02-01'}
    ]
    app.accounts = new Accounts [
      {id: 'ast',  type: 'Asset'},
      {id: 'rev',  type: 'Revenue'},
      {id: 'rev2', type: 'Revenue'},
      {id: 'exp',  type: 'Expense'}
    ]
    app.channels  = new Channels [
      {id: 'channel1'},
      {id: 'channel2'}
    ]
    app.segments  = new Segments [
      {id: 'segment1'},
      {id: 'segment2'}
    ]
    app.customers = new Customers [
      {id: 'customer1', channel_id: 'channel1', segment_id: 'segment1'},
      {id: 'customer2', channel_id: 'channel1', segment_id: 'segment1'},
      {id: 'customer3', channel_id: 'channel2', segment_id: 'segment2'}
    ]
    app.financialSummary = new FinancialSummary [
      {period_id: 'last-month', account_id: 'rev',  customer_id: 'customer1', amount_cents: 100},
      {period_id: 'this-month', account_id: 'rev',  customer_id: 'customer1', amount_cents: 100},
      {period_id: 'this-month', account_id: 'ast',  customer_id: 'customer1', amount_cents: 300},
      {period_id: 'this-month', account_id: 'rev2', customer_id: 'customer1', amount_cents: 200},
      {period_id: 'this-month', account_id: 'rev',  customer_id: 'customer2', amount_cents: 123},
      {period_id: 'this-month', account_id: 'rev',  customer_id: 'customer3', amount_cents: 456},
      {period_id: 'this-month', account_id: 'exp',  customer_id: 'customer1', amount_cents: 200}
    ]

  # default revenue is:
  #   actual => sum of financial summary where account type is revenue for
  #     that period
  #   plan   => sum of revenue plan for all segments for that period
  describe 'default revenue', ->
    beforeEach ->
      spyOn(app.segments, 'revenue').andCallFake (periodId, segmentId) ->
        switch periodId
          when 'last-month'
            segment1: {actual: 10, plan: 40},
            segment2: {actual: 20, plan: 50},
            segment3: {actual: 30, plan: 60},
          when 'this-month'
            segment1: {actual: 20, plan: 50},
            segment2: {actual: 30, plan: 60},
            segment3: {actual: 40, plan: 70},
          when 'next-month'
            segment1: {            plan: 60},
            segment2: {            plan: 70},
            segment3: {            plan: 80},
      @revenue = new Revenue()

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@revenue.get 'last-month').toEqual actual: 100, plan: 150
        expect(@revenue.get 'this-month').toEqual actual: 879, plan: 180
        expect(@revenue.get 'next-month').toEqual              plan: 210

      it 'returns an array with period ids', ->
        result = @revenue.get ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # customer revenue is:
  #   actual => sum of financial summary where account type is revenue for
  #     that period for that customer
  #   plan   => [...does not apply...]
  describe 'customer revenue', ->
    beforeEach ->
      @customer = app.customers.get('customer1')

    describe 'get', ->
      it 'returns actual only', ->
        expect(@customer.revenue 'last-month').toEqual actual: 100
        expect(@customer.revenue 'this-month').toEqual actual: 300

      it 'returns an array with period ids', ->
        result = @customer.revenue ['last-month', 'this-month']
        expect(_.keys(result).length).toEqual 2

  # segment revenue is:
  #   actual => sum of financial summary where account type is revenue for
  #     customers mapped to that segment
  #   plan   => plan segment customer volume * plan segment unit revenue
  describe 'segment revenue', ->
    beforeEach ->
      @segment = app.segments.get('segment1')

      spyOn(@segment, 'unitRevenue').andCallFake (periodId) ->
        switch periodId
          when 'last-month' then actual: 10, plan: 50
          when 'this-month' then actual: 20, plan: 60
          when 'next-month' then             plan: 70
      spyOn(@segment, 'customerVolume').andCallFake (periodId) ->
        switch periodId
          when 'last-month' then actual: 1, plan: 4
          when 'this-month' then actual: 2, plan: 5
          when 'next-month' then            plan: 6

    describe 'get', ->
      it 'returns actual only'#, ->
        # expect(@segment.revenue 'last-month').toEqual actual: 100, plan: 200
        # expect(@segment.revenue 'this-month').toEqual actual: 423, plan: 300
        # expect(@segment.revenue 'next-month').toEqual plan: 420

      it 'returns an array with period ids'#, ->
        # result = @segment.revenue ['last-month', 'this-month', 'next-month']
        # expect(_.keys(result).length).toEqual 3

  # channel revenue is:
  #   actual => sum of financial summary where account type is revenue for
  #     customers mapped to that channel
  #   plan   => sum of (plan segment revenue * customer-segment mix)
  describe 'channel revenue', ->
    beforeEach ->
      @channel = app.channels.get('channel1')
      spyOn(@channel, 'segmentMix').andCallFake (periodId) ->
        switch periodId
          when 'last-month'
            segment1: {actual: 0.7, plan: 0.35}
            segment2: {actual: 0.3, plan: 0.95}
          when 'this-month'
            segment1: {actual: 0.7, plan: 0.45}
            segment2: {actual: 0.3, plan: 0.85}
          when 'next-month'
            segment1: {actual: 0.7, plan: 0.12}
            segment2: {actual: 0.3, plan: 0.90}
      spyOn(app.segments, 'revenue').andCallFake (periodId, segmentId) ->
        switch periodId
          when 'last-month'
            switch segmentId
              when 'segment1' then actual: 1000, plan: 5000
              when 'segment2' then actual: 2000, plan: 6000
          when 'this-month'
            switch segmentId
              when 'segment1' then actual: 3000, plan: 7000
              when 'segment2' then actual: 4000, plan: 8000
          when 'next-month'
            switch segmentId
              when 'segment1' then               plan: 9000
              when 'segment2' then               plan: 1234

    describe 'get', ->
      it 'returns actual only', ->
        expect(@channel.revenue 'last-month').toEqual actual: 100, plan: (0.35 * 5000 + 0.95 * 6000)
        expect(@channel.revenue 'this-month').toEqual actual: 423, plan: (0.45 * 7000 + 0.85 * 8000)
        expect(@channel.revenue 'next-month').toEqual              plan: (0.12 * 9000 + 0.90 * 1234)

      it 'returns an array with period ids', ->
        result = @channel.revenue ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3
