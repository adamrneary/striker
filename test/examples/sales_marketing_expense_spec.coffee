SalesMarketingExpense = require('striker/sales_marketing_expense')
Accounts              = require('collections/accounts')
Periods               = require('collections/periods')
Channels              = require('collections/channels')
FinancialSummary      = require('collections/financial_summary')

describe 'sales & marketing expense', ->
  beforeEach ->
    app.periods  = new Periods [
      {id: 'last-month',    first_day: '2012-01-01'},
      {id: 'this-month',    first_day: '2012-02-01'},
      {id: 'next-month',    first_day: '2012-03-01'},
      {id: 'two-years-ago', first_day: '2010-02-14'}
    ]
    app.channels = new Channels [{id: 'channel1'}, {id: 'channel2'}]
    app.accounts = new Accounts [
      {id: 'rev'},
      {id: 'cac',  activecell_category: 'sales & marketing', channel_id: 'channel1'},
      {id: 'cac2', activecell_category: 'sales & marketing', channel_id: 'channel2'},
    ]
    app.financialSummary = new FinancialSummary [
      {period_id: 'last-month', account_id: 'rev',  amount_cents: 100},
      {period_id: 'last-month', account_id: 'cac2', amount_cents: 200},
      {period_id: 'last-month', account_id: 'cac2', amount_cents: 300},
      {period_id: 'last-month', account_id: 'cac',  amount_cents: 100},
      {period_id: 'this-month', account_id: 'cac2', amount_cents: 50},
      {period_id: 'this-month', account_id: 'rev',  amount_cents: 200},
      {period_id: 'next-month', account_id: 'rev',  amount_cents: 300},
      {period_id: 'next-month', account_id: 'cac',  amount_cents: 200},
      {period_id: 'next-month', account_id: 'cac',  amount_cents: 200},
      {period_id: 'next-month', account_id: 'rev',  amount_cents: 500},
    ]
    stubCurrentDate '2012-02-14'

  # default sales & marketing expense is:
  #   actual => sum of financial summary where expense group is cac for
  #     that period
  #   plan   => sum of s&m expense plan for all channels
  describe 'default sales & marketing expense', ->
    beforeEach ->
      spyOn(app.channels, 'salesMarketingExpense').andCallFake (periodId) ->
        switch periodId
          when 'last-month'
            channel1: {actual: 10, plan: 40},
            channel2: {actual: 20, plan: 50},
            channel3: {actual: 30, plan: 60}
          when 'this-month'
            channel1: {actual: 20, plan: 50},
            channel2: {actual: 30, plan: 60},
            channel3: {actual: 40, plan: 70}
          when 'next-month'
            channel1: {plan: 60},
            channel2: {plan: 70},
            channel3: {plan: 80}
      @analysis = new SalesMarketingExpense()

    describe 'get', ->
      it 'returns an actual/plan object', ->
        expect(@analysis.get 'last-month').toEqual actual: 600, plan: 150
        expect(@analysis.get 'this-month').toEqual actual: 50,  plan: 180
        expect(@analysis.get 'next-month').toEqual actual: 400, plan: 210

      it 'returns an array with period ids', ->
        result = @analysis.get ['last-month', 'this-month', 'next-month']
        expect(_.keys(result).length).toEqual 3

  # channel sales & marketing expense is:
  #   actual => sum of fin. summary where account is mapped to that channel
  #   plan   => sum of (unit cac * conversion volume) for stages, given lag
  describe 'channel sales & marketing expense', ->
    beforeEach ->
      @channel = app.customers.get('channel1')

    # describe 'get' ->
    #   it 'returns an actual/plan object', ->
    #     expect(@analysis.get 'last-month').toEqual actual: 600
    #     expect(@analysis.get 'this-month').toEqual actual: 50
    #     expect(@analysis.get 'next-month').toEqual actual: 400
    #
    #   it 'returns an array with period ids', ->
    #     result = @analysis.get ['last-month', 'this-month', 'next-month']
    #     expect(_.keys(result).length).toEqual 3

  # customer sales & marketing expense is:
  #   actual => sum (channel cac / channel conversion) for stages, given lag
  #   plan   => [...does not apply...]
  describe 'customer sales & marketing expense', ->
    beforeEach ->
      @customer = app.customers.get('customer1')

    # describe 'get', ->
    #      it 'returns actual only', ->
    #        expect(@customer.sales_marketing_expense 'last-month').toEqual actual: 100
    #        expect(@customer.sales_marketing_expense 'this-month').toEqual actual: 300
    #
    #      it 'returns an array with period ids', ->
    #        result = @customer.sales_marketing_expense ['last-month', 'this-month']
    #        expect(_.keys(result).length).toEqual 2