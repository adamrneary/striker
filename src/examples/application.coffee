init = (name, options = {}) ->
  Collection = require("examples/#{name}")
  new Collection(options)

$ ->
  return unless typeof mocha is 'undefined'
  return unless _.include(['/', '/performance'], location.pathname)
  window.app = {}

  # Setup collections
  app.periods  = init 'collections/periods', [
    { id: 'last-month',    first_day: '2012-01-01' }
    { id: 'this-month',    first_day: '2012-02-01' }
    { id: 'next-month',    first_day: '2012-03-01' }
    { id: 'two-years-ago', first_day: '2010-02-01' }
  ]
  app.accounts = init 'collections/accounts', [
    { id: 'ast',  type: 'Asset' }
    { id: 'rev',  type: 'Revenue' }
    { id: 'rev2', type: 'Revenue' }
    { id: 'exp',  type: 'Expense' }
  ]
  app.customers = init 'collections/customers', [
    { id: 'customer1', channel_id: 'channel1', segment_id: 'segment1' }
    { id: 'customer2', channel_id: 'channel1', segment_id: 'segment1' }
    { id: 'customer3', channel_id: 'channel2', segment_id: 'segment2' }
  ]
  app.channels = init 'collections/channels', [
    {id: 'channel1', name: 'Channel 1'}
    {id: 'channel2', name: 'Channel 2'}
  ]
  app.stages   = init 'collections/stages', [
    {id: 'topline', position: 2, name: 'Stage 1 (Topline)'}
    {id: 'customer', position: 1, name: 'Stage 3 (Customer)'}
  ]
  app.conversionSummary  = init 'collections/conversion_summary', [
    { period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 1 }
    { period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 2 }
    { period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 3 }
    { period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 4 }
    { period_id: 'this-month', stage_id: 'customer', channel_id: 'channel1', customer_volume: 5 }
  ]
  app.conversionForecast = init 'collections/conversion_forecast', [
    { period_id: 'last-month', channel_id: 'channel1', stage_id: 'topline', value: 6 }
    { period_id: 'last-month', channel_id: 'channel2', stage_id: 'topline', value: 7 }
    { period_id: 'this-month', channel_id: 'channel1', stage_id: 'topline', value: 8 }
    { period_id: 'this-month', channel_id: 'channel2', stage_id: 'topline', value: 9 }
    { period_id: 'next-month', channel_id: 'channel1', stage_id: 'topline', value: 10 }
    { period_id: 'next-month', channel_id: 'channel2', stage_id: 'topline', value: 11 }
    { period_id: 'this-month', channel_id: 'channel1', stage_id: 'customer', value: 12 }
  ]
  app.financialSummary = init 'collections/financial_summary', [
    { period_id: 'last-month', account_id: 'rev',  customer_id: 'customer1', amount_cents: 100 }
    { period_id: 'this-month', account_id: 'rev',  customer_id: 'customer1', amount_cents: 100 }
    { period_id: 'this-month', account_id: 'ast',  customer_id: 'customer1', amount_cents: 300 }
    { period_id: 'this-month', account_id: 'rev2', customer_id: 'customer1', amount_cents: 200 }
    { period_id: 'this-month', account_id: 'rev',  customer_id: 'customer2', amount_cents: 123 }
    { period_id: 'this-month', account_id: 'rev',  customer_id: 'customer3', amount_cents: 456 }
    { period_id: 'this-month', account_id: 'exp',  customer_id: 'customer1', amount_cents: 200 }
  ]

  # Setup strikers
  # ...

  # Init view
  switch location.pathname
    when '/'            then new init('views/index').render()
    when '/performance' then new init('views/performance')
