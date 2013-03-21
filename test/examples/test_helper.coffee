beforeEach ->
  window.app = {}

window.stubCurrentDate = (date) ->
  spyOn(moment.fn, 'startOf').andReturn moment(date)

Striker.setSchemaMap (key) ->
  switch key
    when 'customer_id' then app.customers.models
    when 'period_id'   then app.periods.models
