CustomerRevenue  = require('striker/customer_revenue')
Accounts         = require('collections/accounts')
Periods          = require('collections/periods')
Customers        = require('collections/customers')
FinancialSummary = require('collections/financial_summary')

# Customer revenue analysis striker
# Revenue is amount of money made over a period of time, even if the cash comes
# in later.
#
# For example, if you work on a client project and bill him for $1,000 in
# January but he pays you in February, your $1,000 is still revenue for
# January in what is called the "accrual system" (which Activecell uses).
#
# To calculate, we basically filter FinancialSummary to revenue accounts and
# group by customer.
#
#   actual   => an Integer representing cents (not $$$), summed from
#                 FinancialSummary (null for future periods)
#   plan     => (does not apply to customers)
#   variance => (does not apply to customers)
describe 'customer revenue', ->
  beforeEach ->
    app.periods  = new Periods [
      { id: 'last-month',    first_day: '2012-01-01' }
      { id: 'this-month',    first_day: '2012-02-01' }
      { id: 'next-month',    first_day: '2012-03-01' }
      { id: 'two-years-ago', first_day: '2010-02-01' }
    ]
    app.accounts = new Accounts [
      { id: 'ast',  type: 'Asset' }
      { id: 'rev',  type: 'Revenue' }
      { id: 'rev2', type: 'Revenue' }
      { id: 'exp',  type: 'Expense' }
    ]
    app.customers = new Customers [
      { id: 'customer1', channel_id: 'channel1', segment_id: 'segment1' }
      { id: 'customer2', channel_id: 'channel1', segment_id: 'segment1' }
      { id: 'customer3', channel_id: 'channel2', segment_id: 'segment2' }
    ]
    app.financialSummary = new FinancialSummary [
      { period_id: 'last-month', account_id: 'rev',  customer_id: 'customer1', amount_cents: 100 }
      { period_id: 'this-month', account_id: 'rev',  customer_id: 'customer1', amount_cents: 100 }
      { period_id: 'this-month', account_id: 'ast',  customer_id: 'customer1', amount_cents: 300 }
      { period_id: 'this-month', account_id: 'rev2', customer_id: 'customer1', amount_cents: 200 }
      { period_id: 'this-month', account_id: 'rev',  customer_id: 'customer2', amount_cents: 123 }
      { period_id: 'this-month', account_id: 'rev',  customer_id: 'customer3', amount_cents: 456 }
      { period_id: 'this-month', account_id: 'exp',  customer_id: 'customer1', amount_cents: 200 }
    ]

    app.customerRevenue = new CustomerRevenue()
    app.customerRevenue.enable()

  describe 'overall revenue', ->
    describe 'get', ->
      it 'calculates values for a single customer and period', ->
        result = app.customerRevenue.get('customer1', 'this-month')
        expect(result.actual).toEqual 100 + 200
        expect(result.plan).toBeUndefined()
        expect(result.variance).toBeUndefined()

      it 'contains nothing for future months', ->
        result = app.customerRevenue.get('customer1', 'next-month')
        expect(result.actual).toBeUndefined()
        expect(result.plan).toBeUndefined()
        expect(result.variance).toBeUndefined()

      it 'returns an array of objects (all periods) by default', ->
        result = app.customerRevenue.flat()
        expect(_.isArray(result)).toBeTruthy()
        expect(_.size(result)).toEqual 12
        console.log result
        expect(result[0]['customer_id']).toEqual 'customer1'
        expect(result[0]['period_id']).toEqual 'last-month'
        expect(result[0]['actual']).toEqual 100
        expect(result[0]['plan']).toBeUndefined()
        expect(result[0]['variance']).toBeUndefined()
        expect(result[1]['customer_id']).toEqual 'customer1'
        expect(result[1]['period_id']).toEqual 'this-month'
        expect(result[1]['actual']).toEqual (100+200)
        expect(result[1]['plan']).toBeUndefined()
        expect(result[1]['variance']).toBeUndefined()

      it 'returns object with all periods for customer', ->
        result = app.customerRevenue.get('customer1')
        expect(_.size(result)).toEqual 4

        lastMonth = result['last-month']
        expect(lastMonth.actual).toEqual 100
        expect(lastMonth.plan).toBeUndefined()
        expect(lastMonth.variance).toBeUndefined()

    describe 'triggers', ->
      it 'responds to changes in financialSummary', ->
        model = app.financialSummary.findWhere(
          { period_id: 'last-month', account_id: 'rev',  customer_id: 'customer1' }
        )
        model.set(amount_cents: 123)

        result = app.customerRevenue.get('customer1', 'last-month')
        expect(result.actual).toEqual 123

  describe 'for customer', ->
    beforeEach ->
      @customer = app.customers.get('customer1')

    describe 'get', ->
      it 'calculates values for a single period', ->
        result = @customer.revenue 'this-month'
        expect(result['actual']).toEqual 100 + 200
        expect(result['plan']).toBeUndefined
        expect(result['variance']).toBeUndefined

      it 'contains nothing for future months', ->
        result = @customer.revenue 'next-month'
        expect(result['actual']).toBeUndefined
        expect(result['plan']).toBeUndefined
        expect(result['variance']).toBeUndefined

      it 'returns an array of objects (all periods) by default', ->
        result = @customer.revenue()
        expect(_.isArray(result)).toBeTruthy()
        expect(_.size(result)).toEqual 4

        lastMonth = result[0]
        expect(lastMonth.period_id).toEqual 'last-month'
        expect(lastMonth.actual).toEqual 100
        expect(lastMonth.plan).toBeUndefined()
        expect(lastMonth.variance).toBeUndefined()

    describe 'triggers', ->
      it 'responds to changes in financialSummary', ->
        model = app.financialSummary.findWhere(
          { period_id: 'last-month', account_id: 'rev', customer_id: 'customer1' }
        )
        model.set(amount_cents: 123)

        result = @customer.revenue 'last-month'
        expect(result['actual']).toEqual 123
