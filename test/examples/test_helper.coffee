beforeEach ->
  window.app = {}

  # stub current Date
  Periods = require('collections/periods')
  spyOn(Periods::, 'compare').andCallFake (date1, date2) ->
    new Date(date1).getTime() > new Date('2012-02-14T14:25:30.000Z').getTime()

Striker.setSchemaMap (key) ->
  switch key
    when 'channel_id'  then app.channels.models
    when 'customer_id' then app.customers.models
    when 'period_id'   then app.periods.models
