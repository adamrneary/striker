FinancialSummary = require('collections/financial_summary')

module.exports = class Account extends Backbone.Model
  paramRoot: 'account'

  # dimension methods

  # retrieves children of the account as a collection
  #
  # returns Accounts backbone collection
  children: =>
    app.accounts.wrappedWhere (model) =>
      @get('id') is model.get('parent_account_id')

  parent: =>
    app.accounts.get(@get('parent_account_id'))

  # retrieves parent of the account as a model
  #
  # returns Account backbone model
  parent: =>
    app.accounts.get @get('parent_account_id')

  # fact methods

  # calculates the sum of amounts for financial summary records for the account
  #   within the current filtered timeframe
  #
  # returns an Integer representing the amount in cents
  totalOver: =>
    app.financialSummaryCrossfilter?.forAccountId @get('id')

  # calculates the sum of totalOver value for the account and all its children
  #
  # returns an Integer representing the amount in cents
  recursiveTotal: =>
    @totalOver() + _.reduce(
      @children().map((account) -> account.recursiveTotal())
      (memo, num) -> memo + num
      0
    )

  # calculates the sum of amounts for financial summary records for the account
  #   between the current period and the end of the current filtered timeframe
  #
  # returns an Integer representing the amount in cents
  totalSince: =>
    app.accountBalanceCrossfilter.forAccountId @get('id')

  # calculates the account's balance as of end of the passed period by
  #   subtracting the sum of transactions since the current period from the
  #   current balance. for future periods, returns the current balance
  #
  # examples:
  #
  #   # timeframe ending with current period
  #   app.state.set(timeframe: [-2,0])
  #   account.get('current_balance')
  #   => 1000
  #   account.totalSince()
  #   => 0
  #   account.balanceAsOf()
  #   => 1000
  #
  #   # timeframe ending with prior period
  #   app.state.set(timeframe: [-6,-2])
  #   account.get('current_balance')
  #   => 1000
  #   account.totalSince()
  #   => 200
  #   account.balanceAsOf()
  #   => 800
  #
  #   # timeframe ending with future period
  #   app.state.set(timeframe: [-4,6])
  #   account.get('current_balance')
  #   => 1000
  #   account.totalSince()
  #   => 0
  #   account.balanceAsOf()
  #   => 1000
  #
  # returns an Integer representing the amount in cents
  balanceAsOf: ->
    @get('current_balance') - @totalSince()

  # calculates the sum of balanceAsOf value for the account and all its children
  #
  # returns an Integer representing the amount in cents
  recursiveBalanceAsOf: =>
    @balanceAsOf() + _.reduce(
      @children().map((account) -> account.recursiveBalanceAsOf())
      (memo, num) -> memo + num
      0
    )


  ###################
  # Legacy
  ###################

  # TODO: eliminate in favor of collection methods
  isRevenue: -> @get('type') is 'Revenue'
  isExpense: -> @get('type') is 'Expense'
  isSalesMarketing: -> @get('activecell_category') is 'sales & marketing'

  # TODO: rethink this! :-)
  trailing12m: ->
    # @totalOver()
    @get('name').length * 100
