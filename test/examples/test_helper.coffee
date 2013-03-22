beforeEach ->
  window.app = {}

window.stubCurrentDate = (date) ->
  spyOn(Date, 'now').andReturn((new Date date) - 1)

Striker.setSchemaMap (key) ->
  switch key
    when 'channel_id'  then app.channels.models
    when 'customer_id' then app.customers.models
    when 'period_id'   then app.periods.models
