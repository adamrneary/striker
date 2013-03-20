ConversionRate = require('striker/conversion_rate')
Conversion     = require('striker/conversion')
Periods        = require('collections/periods')
Channels       = require('collections/channels')
Stages         = require('collections/stages')

# conversionRate(stage a, period b) = conversion(stage a, period b)
#                                   / conversion(stage a-1, period b-1)
#   where period b-1 considers the lag periods for stage a
#   where period b-1 does not exist, return null
describe 'conversion rate', ->
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
    app.stages   = new Stages [
      {id: 'prospect',  position: 3, lag_periods: 1},
      {id: 'lead',      position: 2},
      {id: 'customer',  position: 1}
    ]
    app.conversion = new Conversion()

  # default conversion rate is awesome.
  describe 'default conversion rate', ->
    beforeEach ->
      spyOn(Conversion::, 'get').andCallFake (periodId) ->
        switch periodId
          when 'last-month'
            prospect: {actual: 100, plan: 300}
            lead:     {actual:  50, plan:  30}
            customer: {actual:  10, plan:   6}
          when 'this-month'
            prospect: {actual: 200, plan: 400}
            lead:     {actual:  40, plan:  20}
            customer: {actual:   9, plan:   7}
          when 'next-month'
            prospect: {             plan: 500}
            lead:     {             plan:  10}
            customer: {             plan:   8}

      @conversionRate = new ConversionRate()

    describe 'get', ->
      # it 'calculates values for all stages except topline', ->
      #   result = @conversionRate.get('this-month')
      #   expect(_.keys(result).length).toEqual 2
      #
      #   # prospect is null because it is the topline stage
      #   expect(result['prospect']).toBeNull
      #
      #   # lead uses the previous period because prospect has a lag of 1
      #   expect(result['lead']).toEqual     actual: (40/100), plan: (20/300)
      #
      #   # customer uses the current period because lead has a lag of 0
      #   # actual: 0.225, plan: 0.35
      #   expect(result['customer']).toEqual actual: (9/40),   plan: (7/20)
      #
      # it 'contains no "actuals" for a future month', ->
      #   result = @conversionRate.get('next-month')
      #   expect(result['lead']).toEqual     plan: (10/400)
      #   expect(result['customer']).toEqual plan: (8/10)
      #
      # it 'return null if the previous period is unavailable due to lag periods', ->
      #   result = @conversionRate.get('last-month')
      #   expect(result['lead']).toBeNull
      #
      # it 'contains object grouped by period and stage', ->
      #   result = @conversionRate.get ['last-month', 'this-month', 'next-month']
      #   expect(result['last-month']['customer']).toEqual actual: (10/50), plan: (6/30)

  # channel conversion rate is awesome.
  describe 'channel conversion rate', ->
    beforeEach ->
      @channel = app.channels.get('channel1')
      spyOn(@channel, 'conversion').andCallFake (periodId) ->
        switch periodId
          when 'last-month'
            prospect: {actual: 100, plan: 300}
            lead:     {actual:  50, plan:  30}
            customer: {actual:  10, plan:   6}
          when 'this-month'
            prospect: {actual: 200, plan: 400}
            lead:     {actual:  40, plan:  20}
            customer: {actual:   9, plan:   7}
          when 'next-month'
            prospect: {             plan: 500}
            lead:     {             plan:  10}
            customer: {             plan:   8}

    describe 'get', ->
      # it 'calculates values for all stages except topline', ->
      #   result = @channel.conversionRate('this-month')
      #   expect(_.keys(result).length).toEqual 2
      #
      #   # prospect is null because it is the topline stage
      #   expect(result['prospect']).toBeNull
      #
      #   # lead uses the previous period because prospect has a lag of 1
      #   expect(result['lead']).toEqual     actual: (40/100), plan: (20/300)
      #
      #   # customer uses the current period because lead has a lag of 0
      #   expect(result['customer']).toEqual actual: (9/40),   plan: (7/20)
      #
      # it 'contains no "actuals" for a future month', ->
      #   result = @channel.conversionRate('next-month')
      #   expect(result['lead']).toEqual     plan: (10/400)
      #   expect(result['customer']).toEqual plan: (8/10)
      #
      # it 'return null if the previous period is unavailable due to lag periods', ->
      #   result = @channel.conversionRate('last-month')
      #   expect(result['lead']).toBeNull
      #
      # it 'contains object grouped by period and stage', ->
      #   result = @channel.conversionRate ['last-month', 'this-month', 'next-month']
      #   expect(result['last-month']['customer']).toEqual actual: (10/50), plan: (6/30)
