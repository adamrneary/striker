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

window.app = {}
describe 'Reach integration test', ->
  expect = chai.expect

  initCache = ->
    Striker.schemaMap = (key) ->
      switch key
        when 'period_id'  then app.periods.models
        when 'channel_id' then app.channels.models

  beforeEach ->
    entries.Periods::_startOfMonth = -> moment('2012-02-14')

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
    describe 'get and flat', ->
      it 'calculates values for a single channel and period', ->
        result = app.reach.get('channel1', 'last-month')
        expect(result.actual).equal(1)
        expect(result.plan).equal(6)
        expect(result.variance).equal(1-6)

      it 'contains no "actual" or "variance" for future months', ->
        result = app.reach.get('channel1', 'next-month')
        expect(result['actual']).undefined
        expect(result['plan']).equal 10
        expect(result['variance']).undefined

      it 'returns an array of objects (all periods) by default', ->
        result = app.reach.flat()
        expect(_.isArray(result)).true
        expect(_.size(result)).equal 8

        expect(result[1]['channel_id']).equal 'channel1'
        expect(result[1]['period_id']).equal 'last-month'
        expect(result[1]['actual']).equal 1
        expect(result[1]['plan']).equal 6
        expect(result[1]['variance']).equal (1-6)

    describe 'reverse', ->
      beforeEach ->
        @result = app.reach.reverse()
        console.log @result

      it 'has periodIds at the top key of the returned collection', ->
        expect(_.size(@result)).equal 4
        _.map app.periods.ids(), (pId) =>
          expect(@result[pId]).exist

      it 'has channelId as the lowest level key', ->
        expect(@result['this-month'].channel1.actual).equal 3
        expect(@result['this-month'].channel1.plan).equal 8
        expect(@result['this-month'].channel2.period_id).equal "this-month"

  #   describe 'triggers', ->
  #     it 'responds to changes in conversionSummary', ->
  #       model = app.conversionSummary.findWhere
  #         period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'
  #       model.set(customer_volume: 2)

  #       result = app.reach.get('channel1', 'last-month')
  #       expect(result['actual']).equal 2
  #       expect(result['plan']).equal 6
  #       expect(result['variance']).equal (2-6)

  #     it 'responds to changes in conversionForecast', ->
  #       model = app.conversionForecast.findWhere
  #         period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'
  #       model.set(value: 9)

  #       result = app.reach.get('channel1', 'last-month')
  #       expect(result['actual']).equal 1
  #       expect(result['plan']).equal 9
  #       expect(result['variance']).equal (1-9)

  # describe 'channel reach', ->
  #   beforeEach ->
  #     @channel = app.channels.get('channel1')

  #   describe 'get', ->
  #     it 'calculates values for a single period', ->
  #       result = @channel.reach 'last-month'
  #       expect(result['actual']).equal 1
  #       expect(result['plan']).equal 6
  #       expect(result['variance']).equal (1-6)

  #     it 'contains no "actuals" for a future month', ->
  #       result = @channel.reach 'next-month'
  #       expect(result['actual']).undefined
  #       expect(result['plan']).equal 10
  #       expect(result['variance']).undefined

  #     it 'returns an array of objects (all periods) by default', ->
  #       result = @channel.reach()
  #       expect(_.isArray(result)).true
  #       expect(_.size(result)).equal 4
  #       expect(result[1]['period_id']).equal 'last-month'
  #       expect(result[1]['actual']).equal 1
  #       expect(result[1]['plan']).equal 6
  #       expect(result[1]['variance']).equal (1-6)

  #   describe 'triggers', ->
  #     it 'responds to changes in conversionSummary', ->
  #       model = app.conversionSummary.findWhere
  #         period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'
  #       model.set(customer_volume: 2)

  #       result = @channel.reach 'last-month'
  #       expect(result['actual']).equal 2
  #       expect(result['plan']).equal 6
  #       expect(result['variance']).equal (2-6)

  #     it 'responds to changes in conversionForecast', ->
  #       model = app.conversionForecast.findWhere
  #         period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1'
  #       model.set(value: 9)

  #       result = @channel.reach 'last-month'
  #       expect(result['actual']).equal 1
  #       expect(result['plan']).equal 9
  #       expect(result['variance']).equal (1-9)
