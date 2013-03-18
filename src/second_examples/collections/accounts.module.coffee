Collection  = require('collections/shared/collection')
Account     = require('models/account')

module.exports = class Accounts extends Collection
  url: 'api/v1/accounts'
  model: Account

  #############################################################################
  # filter methods
  #############################################################################

  noParents: ->
    @wrappedWhere (model) -> model.get('parent_account_id') is null

  getByType: (type) ->
    @wrappedWhere type: type

  revenue: ->
    @wrappedWhere (model) -> model.get('type') is "Revenue"

  cogs: ->
    @wrappedWhere (model) -> model.get('type') is "Cost of Goods Sold"

  expense: ->
    @wrappedWhere (model) -> model.get('type') is "Expense"

  asset: ->
    @wrappedWhere (model) -> model.get('type') is "Asset"

  liability: ->
    @wrappedWhere (model) -> model.get('type') is "Liability"

  equity: ->
    @wrappedWhere (model) -> model.get('type') is "Equity"

  profit_loss: ->
    @wrappedWhere (model) ->
      _.include ['Revenue', 'Cost of Goods Sold', 'Expense'], model.get('type')

  balance_sheet: ->
    @wrappedWhere (model) ->
      _.include ['Asset', 'Liability', 'Equity'], model.get('type')

  #############################################################################
  # aggregation methods
  #############################################################################
  
  assetBalance: =>
    _.reduce( 
      @asset().map((account) -> account.balanceAsOf())
      (memo, num) -> memo + num
      0
    )
  
  liabilityBalance: =>
    _.reduce( 
      @liability().map((account) -> account.balanceAsOf())
      (memo, num) -> memo + num
      0
    )
  
  equityBalance: =>
    _.reduce( 
      @equity().map((account) -> account.balanceAsOf())
      (memo, num) -> memo + num
      0
    )
  
  revenueTotal: ->
    app?.financialSummaryCrossfilter?.forAccountType('Revenue')

  cogsTotal: ->
    app?.financialSummaryCrossfilter?.forAccountType('Cost of Goods Sold')

  expenseTotal: ->
    app?.financialSummaryCrossfilter?.forAccountType('Expense')
