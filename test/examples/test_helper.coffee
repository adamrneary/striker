
window.expect = chai.expect
mocha.setup(globals: ['app'])

# stub current Date
Periods = require('examples/collections/periods')
Periods::compare = (date1, date2) ->
  new Date(date1).getTime() > new Date('2012-02-14T14:25:30.000Z').getTime()

# setup striker
Striker.setSchemaMap (key) ->
  switch key
    when 'channel_id'  then app.channels.models
    when 'customer_id' then app.customers.models
    when 'period_id'   then app.periods.models
    when 'stage_id'    then app.stages.models
    when 'segment_id'  then app.segments.models

beforeEach ->
  window.app = {}
