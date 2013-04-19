Periods = require('examples/collections/periods')
inputs  = require('examples/inputs')

window.expect = chai.expect
mocha.setup(globals: ['app'])

# Reset env for every test
beforeEach ->
  window.app = {}

# Helper for easy loading of necessary data
window.init = (options = {}) ->
  for type in ['collections', 'strikers']
    options[type]?.forEach (fileName) ->
      Collection = require("examples/#{type}/#{fileName}")
      name       = $.camelCase(fileName.replace(/_/g, '-'))
      app[name]  = new Collection(inputs[name])

# Stub current Date
Periods::compare = (date1, date2) ->
  new Date(date1).getTime() > new Date('2012-02-14T14:25:30.000Z').getTime()

# Setup striker
Striker.setSchemaMap (key) ->
  switch key
    when 'channel_id'         then app.channels.models
    when 'customer_id'        then app.customers.models
    when 'period_id'          then app.periods.models
    when 'stage_id'           then app.stages.models
    when 'segment_id'         then app.segments.models
    when 'not_first_stage_id' then app.stages.last(app.stages.length - 1)
