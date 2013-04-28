Periods    = require('examples/collections/periods')
CashOnHand = require('examples/strikers/cash_on_hand')
Accounts   = require('examples/collections/accounts')

#TODO Write a description
describe 'cash_on_hand', ->
  beforeEach ->
    app.periods = new Periods [
      { id: 'last-month',    first_day: '2012-01-01' }
      { id: 'this-month',    first_day: '2012-02-01' }
      { id: 'next-month',    first_day: '2012-03-01' }
      { id: 'two-years-ago', first_day: '2010-02-01' }
    ]
    app.accounts = new Accounts [
      { id: '1',  activecell_category: 'cash',     balance_as_of: '2012-01-01', current_balance: 1 }
      { id: '2',  activecell_category: 'cash',     balance_as_of: '2012-01-01', current_balance: 2 }
      { id: '3',  activecell_category: 'non-cash', balance_as_of: '2012-01-01', current_balance: 3 }
      { id: '4',  activecell_category: 'cash',     balance_as_of: '2012-02-01', current_balance: 4 }
      { id: '5',  activecell_category: 'non-cash', balance_as_of: '2012-02-01', current_balance: 5 }
      { id: '6',  activecell_category: 'cash',     balance_as_of: '2012-03-01', current_balance: 5 }
    ]
    app.cashOnHand = new CashOnHand()

  describe 'overall', ->
    describe 'get', ->
      it 'calculates values for a single period', ->
        result = app.cashOnHand.get('last-month')
        expect(result['actual']).equal(3)

      it 'returns an array of objects (all periods) by default', ->
        result = app.cashOnHand.flat()
        expect(_.isArray(result)).equal(true)
        expect(_.size(result)).equal(4)

        expect(result[0]['period_id']).equal('last-month')
        expect(result[0]['actual']).equal(3)
        expect(result[0]['plan']).equal(undefined)
        expect(result[0]['variance']).equal(undefined)

    describe 'triggers', ->
      it 'responds to changes in accounts', ->
        model = app.accounts.findWhere({activecell_category: 'cash'})
        expect(model.get('id')).equal('1')
        model.set('current_balance', 2)

        result = app.cashOnHand.get('last-month')
        expect(result['actual']).equal(4)
