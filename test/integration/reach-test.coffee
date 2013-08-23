# Reach analysis striker
# Reach (also called "Topline growth") is the conversion number for the topline
# stage. It represents the total number of potential customers a company might
# acquire. For a web company like ours, "reach" might include all potential
# users that visit our website, whether they become paying customers or not.
#
# To calculate, we basically filter conversionSummary and conversionForecast to
# the topline stage and group by channel and period.
#
#   actual   => an Integer from conversionSummary (null for future periods)
#   plan     => an Integer from conversionForecast
#   variance => an Integer (actual - plan) (null for future periods)

describe 'Reach integration test', ->
  app = {}
  expect = chai.expect

  initCache = ->
    Striker.set 'toplineId', app.stages, ->
      app.stages.topline().id

    Striker.schemaMap = (key) ->
      switch key
        when 'period_id'  then app.periods.models
        when 'channel_id' then app.channels.models

  beforeEach ->
    # stubCurrentDate '2012-02-14'
    app.periods = new entries.Periods([
      { id: 'last-month',    first_day: '2012-01-01T00:00:00.000Z' }
      { id: 'this-month',    first_day: '2012-02-01T00:00:00.000Z' }
      { id: 'next-month',    first_day: '2012-03-01T00:00:00.000Z' }
      { id: 'two-years-ago', first_day: '2010-02-01T00:00:00.000Z' }
    ])
    app.channels = new entries.Channels([
      { id: 'channel1' }
      { id: 'channel2' }
    ])
    app.stages = new entries.Stages([
      { id: 'topline', position: 2 }
      { id: 'customer', position: 1 }
    ])
    app.scenario = new entries.Scenario({ id: 'scenario1' })
    app.conversionSummary = new entries.ConversionSummary([
      { period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 1 }
      { period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 2 }
      { period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 3 }
      { period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 4 }
      { period_id: 'this-month', stage_id: 'customer', channel_id: 'channel1', customer_volume: 5 }
    ])
    app.conversionForecast = new entries.ConversionForecast([
      { period_id: 'last-month', channel_id: 'channel1', stage_id: 'topline',  value: 6,  scenario_id: 'scenario1' }
      { period_id: 'last-month', channel_id: 'channel2', stage_id: 'topline',  value: 7,  scenario_id: 'scenario1' }
      { period_id: 'this-month', channel_id: 'channel1', stage_id: 'topline',  value: 8,  scenario_id: 'scenario1' }
      { period_id: 'this-month', channel_id: 'channel2', stage_id: 'topline',  value: 9,  scenario_id: 'scenario1' }
      { period_id: 'next-month', channel_id: 'channel1', stage_id: 'topline',  value: 10, scenario_id: 'scenario1' }
      { period_id: 'next-month', channel_id: 'channel2', stage_id: 'topline',  value: 11, scenario_id: 'scenario1' }
      { period_id: 'this-month', channel_id: 'channel1', stage_id: 'customer', value: 12, scenario_id: 'scenario1' }
    ])
    initCache()
    app.reach = new entries.Reach()

  describe 'overall', ->
    describe 'get', ->
      it 'calculates values for a single channel and period', ->
        result = app.reach.get('channel1', 'last-month')
        expect(result.actual).equal(1)
        expect(result.plan).equal(6)
        expect(result.variance).equal(1-6)
