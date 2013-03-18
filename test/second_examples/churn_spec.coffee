Churn            = require('striker/churn')
ChurnedCustomers = require('striker/churned_customers')
Periods          = require('collections/periods')
Channels         = require('collections/channels')
Segments         = require('collections/segments')

describe 'churn', ->
  beforeEach ->
    stubCurrentDate '2012-02-14'
    app.periods  = new Periods [
      {id: 'last-month',      first_day: '2012-01-01'},
      {id: 'this-month',      first_day: '2012-02-01'},
      {id: 'next-month',      first_day: '2012-03-01'},
      {id: 'following-month', first_day: '2012-04-01'},
      {id: 'two-years-ago',   first_day: '2010-02-01'},
    ]
    app.channels  = new Channels [
      {id: 'channel1'},
      {id: 'channel2'},
    ]
    app.segments  = new Segments [
      {id: 'segment1'},
      {id: 'segment2'},
    ]
    app.churnedCustomers = new ChurnedCustomers()

  # default churn is:
  #   actual => distinct count of churned customers in the period
  #   plan   => sum of segment churn plan for all segments for that period
  describe 'default churn', ->
    beforeEach ->
      spyOn(ChurnedCustomers::, 'get').andCallFake (periodId) ->
        switch periodId
          when 'last-month' then ['customer1', 'customer2']
          when 'this-month' then ['customer3']
      spyOn(app.segments, 'churn').andCallFake (periodId) ->
        switch periodId
          when 'last-month'
            segment1: {actual: 10, plan: 40}
            segment2: {actual: 20, plan: 50}
            segment3: {actual: 30, plan: 60}
          when 'this-month'
            segment1: {actual: 20, plan: 50}
            segment2: {actual: 30, plan: 60}
            segment3: {actual: 40, plan: 70}
          when 'next-month'
            segment1: {            plan: 60}
            segment2: {            plan: 70}
            segment3: {            plan: 80}

      @churn = new Churn()

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@churn.get 'last-month').toEqual actual: 2, plan: 150
        expect(@churn.get 'this-month').toEqual actual: 1, plan: 180
        expect(@churn.get 'next-month').toEqual            plan: 210

      it 'returns an array with period ids', ->
        result = @churn.get ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # segment churn is:
  #   actual => distinct count of segment churned customers in the period
  #   plan   =>  planned churn rate for the segment
  #             * previous period customer volume for the segment
  #
  #             note: churn should be rounded to an integer
  #             note: for previous period customer volume:
  #                   if no previous period exists, use 0
  #                   if actuals exist for previous period, use actuals
  #                   else use plan
  describe 'segment churn', ->
    beforeEach ->
      @segment = app.segments.get('segment1')
      spyOn(@segment, 'churnedCustomers').andCallFake (periodId) ->
        switch periodId
          when 'last-month' then ['customer1', 'customer2']
          when 'this-month' then ['customer3']
      spyOn(@segment, 'customerVolume').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 50,  plan: 60
          when 'this-month'       then actual: 70,  plan: 80
          when 'next-month'       then              plan: 100
          when 'following-month'  then              plan: 120
      spyOn(@segment, 'churnRate').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 0.05,  plan: 0.06
          when 'this-month'       then actual: 0.07,  plan: 0.08
          when 'next-month'       then                plan: 0.10
          when 'following-month'  then                plan: 0.12

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@segment.churn 'last-month').toEqual
          actual: 2
          plan: Math.round(0 * 0.06)
        expect(@segment.churn 'this-month').toEqual
          actual: 1
          plan: Math.round(50 * 0.08)
        expect(@segment.churn 'next-month').toEqual
          plan: Math.round(70 * 0.10)
        expect(@segment.churn 'following-month').toEqual
          plan: Math.round(100 * 0.12)

      it 'returns an array with period ids', ->
        result = @segment.churn ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # channel churn is:
  #   actual => distinct count of channel churned customers in the period
  #   plan   => for each segment in a channel's segment mix,
  #                 previous period customer volume
  #               * that segment's mix (%)
  #               * that segment's churn rate
  #             note: churn should be rounded to an integer
  #             note: for previous period customer volume and segment mix:
  #                   if no previous period exists, use 0
  #                   if actuals exist for previous period, use actuals
  #                   else use plan
  describe 'channel churn', ->
    beforeEach ->
      @channel  = app.channels.get('channel1')
      @segment1 = app.segments.get('segment1')
      @segment2 = app.segments.get('segment2')

      spyOn(@channel, 'churnedCustomers').andCallFake (periodId) ->
        switch periodId
          when 'last-month' then ['customer1', 'customer2']
          when 'this-month' then ['customer3']

      spyOn(@channel, 'segmentMix').andCallFake (periodId) ->
        switch periodId
          when 'last-month'
            segment1: {actual: 0.7, plan: 0.8}
            segment2: {actual: 0.3, plan: 0.2}
          when 'this-month'
            segment1: {actual: 0.7, plan: 0.7}
            segment2: {actual: 0.3, plan: 0.3}
          when 'next-month'
            segment1: {actual: 0.7, plan: 0.6}
            segment2: {actual: 0.3, plan: 0.4}
          when 'following-month'
            segment1: {actual: 0.7, plan: 0.5}
            segment2: {actual: 0.3, plan: 0.5}

      spyOn(@segment1, 'customerVolume').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 50, plan: 60
          when 'this-month'       then actual: 70, plan: 80
          when 'next-month'       then             plan: 100
          when 'following-month'  then             plan: 120

      spyOn(@segment2, 'customerVolume').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 50, plan: 60
          when 'this-month'       then actual: 70, plan: 80
          when 'next-month'       then             plan: 100
          when 'following-month'  then             plan: 120

      spyOn(@segment1, 'churnRate').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 0.01, plan: 0.05
          when 'this-month'       then actual: 0.02, plan: 0.06
          when 'next-month'       then               plan: 0.07
          when 'following-month'  then               plan: 0.08

      spyOn(@segment2, 'churnRate').andCallFake (periodId) ->
        switch periodId
          when 'last-month'       then actual: 0.03, plan: 0.09
          when 'this-month'       then actual: 0.04, plan: 0.10
          when 'next-month'       then               plan: 0.11
          when 'following-month'  then               plan: 0.12

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@channel.churn 'last-month').toEqual
          actual: 2
          plan: Math.round( ( 0 *  0.8 * 0.05) + (  0 * 0.2 * 0.09) )
        expect(@channel.churn 'this-month').toEqual
          actual: 1
          plan: Math.round( ( 50 * 0.7 * 0.06) + ( 50 * 0.3 * 0.10) )
        expect(@channel.churn 'next-month').toEqual
          plan: Math.round( ( 70 * 0.6 * 0.07) + ( 70 * 0.4 * 0.11) )

        # TODO: Adam, is it correct test?
        # expect(@channel.churn 'following-month').toEqual
        #           plan: Math.round( (100 * 0.5 * 0.08) + (100 * 0.5 * 0.12) )
        expect(@channel.churn 'following-month').toEqual
          plan: Math.round( (100 * 0.7 * 0.08) + (100 * 0.3 * 0.12) )

      it 'returns an array with period ids', ->
        result = @channel.churn ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3
