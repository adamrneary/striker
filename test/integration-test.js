/**
 * Reach analysis striker
 * Reach (also called "Topline growth") is the conversion number for the topline
 * stage. It represents the total number of potential customers a company might
 * acquire. For a web company like ours, "reach" might include all potential
 * users that visit our website, whether they become paying customers or not.
 *
 * To calculate, we basically filter conversionSummary and conversionForecast to
 * the topline stage and group by channel and period.
 *
 *   actual   => an Integer from conversionSummary (null for future periods)
 *   plan     => an Integer from conversionForecast
 *   variance => an Integer (actual - plan) (null for future periods)
 */

describe('Integration test', function() {
  var expect  = window.chai.expect, result, channel;
  var Striker = window.Striker, moment = window.moment;
  var app     = {};

  // Define collections
  var Scenario           = Backbone.Model.extend({});
  var Channel            = Backbone.Model.extend({});
  var Channels           = Backbone.Collection.extend({ model: Channel });
  var ConversionSummary  = Backbone.Collection.extend({});
  var ConversionForecast = Backbone.Collection.extend({});

  var Stages = Backbone.Collection.extend({
    topline: function() {
      return this.max(function(stage) { return stage.get('position') });
    }
  });

  var Periods = Backbone.Collection.extend({
    comparator: function(period) {
      return moment(period.get('first_day')).unix();
    },

    ids: function() { return this.pluck('id') },

    idToUnix: function(periodId) {
      return moment(this.get(periodId).get('first_day'))
        .add('days', 1)
        .unix() * 1000;
    },

    notFuture: function(periodId) {
      return moment(this.get(periodId).get('first_day')) <= moment('2012-02-14');
    }
  });

  var Reach = Striker.extend({
    schema: ['channel_id', 'period_id'],
    observers: {
      conversionSummary: observer,
      conversionForecast: observer
    },

    calculate: function(channelId, periodId) {
      var con1 = { stage_id: app.stages.topline().id, channel_id: channelId, period_id: periodId };
      var con2 = _.extend({ scenario_id: app.scenario.id }, con1);

      var conversionSummary  = app.conversionSummary.where(con1);
      var conversionForecast = app.conversionForecast.where(con2);
      var actual             = sum(conversionSummary, 'customer_volume');
      var plan               = sum(conversionForecast, 'value');
      var notFuture          = app.periods.notFuture(periodId);

      return {
        periodUnix: app.periods.idToUnix(periodId),
        actual:     notFuture ? actual : undefined,
        plan:       plan,
        variance:   notFuture ? actual - plan : undefined
      };
    }
  });

  function sum(collection, field) {
    return collection.reduce(function(memo, item){
      return memo + item.get(field);
    }, 0);
  }

  function observer(model) {
    if (model.get('stage_id') !== app.stages.topline().id) return;
    this.update(model.get('channel_id'), model.get('period_id'));
  }

  // apply plugins to improve performance
  Backbone.Memoize(Stages, ['topline']);
  Backbone.Memoize(Periods, ['ids', 'idToUnix', 'notFuture']);
  Backbone.Index(ConversionSummary);
  Backbone.Index(ConversionForecast);

  before(function() {
    // Setup Striker
    Striker.namespace = app;
    Striker.schemaMap = function(key) {
      switch (key) {
        case 'period_id': return app.periods.models;
        case 'channel_id': return app.channels.models;
      }
    };
    Striker.addAnalysis(Channel, 'reach');
  });

  beforeEach(function() {
    app.periods = new Periods([
      { id: 'last-month',    first_day: '2012-01-01T00:00:00.000Z' },
      { id: 'this-month',    first_day: '2012-02-01T00:00:00.000Z' },
      { id: 'next-month',    first_day: '2012-03-01T00:00:00.000Z' },
      { id: 'two-years-ago', first_day: '2010-02-01T00:00:00.000Z' }
    ]);
    app.channels = new Channels([
      { id: 'channel1' },
      { id: 'channel2' }
    ]);
    app.stages = new Stages([
      { id: 'topline', position: 2 },
      { id: 'customer', position: 1 }
    ]);
    app.scenario = new Scenario({ id: 'scenario1' });
    app.conversionSummary = new ConversionSummary([
      { period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 1 },
      { period_id: 'last-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 2 },
      { period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel1', customer_volume: 3 },
      { period_id: 'this-month', stage_id: 'topline',  channel_id: 'channel2', customer_volume: 4 },
      { period_id: 'this-month', stage_id: 'customer', channel_id: 'channel1', customer_volume: 5 }
    ]);
    app.conversionForecast = new ConversionForecast([
      { period_id: 'last-month', channel_id: 'channel1', stage_id: 'topline',  value: 6,  scenario_id: 'scenario1' },
      { period_id: 'last-month', channel_id: 'channel2', stage_id: 'topline',  value: 7,  scenario_id: 'scenario1' },
      { period_id: 'this-month', channel_id: 'channel1', stage_id: 'topline',  value: 8,  scenario_id: 'scenario1' },
      { period_id: 'this-month', channel_id: 'channel2', stage_id: 'topline',  value: 9,  scenario_id: 'scenario1' },
      { period_id: 'next-month', channel_id: 'channel1', stage_id: 'topline',  value: 10, scenario_id: 'scenario1' },
      { period_id: 'next-month', channel_id: 'channel2', stage_id: 'topline',  value: 11, scenario_id: 'scenario1' },
      { period_id: 'this-month', channel_id: 'channel1', stage_id: 'customer', value: 12, scenario_id: 'scenario1' }
    ]);
    app.reach = new Reach();
  });

  describe('overall', function() {
    describe('get', function() {
      it('calculates values for a single channel and period', function() {
        result = app.reach.get('channel1', 'last-month');
        expect(result.actual).equal(1);
        expect(result.plan).equal(6);
        expect(result.variance).equal(1 - 6);
      });

      it('contains no "actual" or "variance" for future months', function() {
        result = app.reach.get('channel1', 'next-month');
        expect(result.actual).undefined;
        expect(result.plan).equal(10);
        expect(result.variance).undefined;
      });

      it('returns an array of objects (all periods) by default', function() {
        result = app.reach.entries;
        expect(_.isArray(result)).true;
        expect(_.size(result)).equal(8);

        expect(result[1].get('channel_id')).equal('channel1');
        expect(result[1].get('period_id')).equal('last-month');
        expect(result[1].get('actual')).equal(1);
        expect(result[1].get('plan')).equal(6);
        expect(result[1].get('variance')).equal(1 - 6);
      });
    });

    describe('reverseValues', function() {
      beforeEach(function() {
        result = app.reach.reverseValues();
      });

      it('has periodIds at the top key of the returned collection', function() {
        expect(_.size(result)).equal(4);
        app.periods.ids().forEach(function(pId) {
          expect(result[pId]).exist;
        });
      });

      it('has channelId as the lowest level key', function() {
        expect(result['this-month'].channel1.actual).equal(3);
        expect(result['this-month'].channel1.plan).equal(8);
        expect(result['this-month'].channel2.period_id).equal('this-month');
      });
    });

    describe('observers', function() {
      it('responds to changes in conversionSummary', function() {
        getModel(app.conversionSummary).set({ customer_volume: 2 });

        result = app.reach.get('channel1', 'last-month');
        expect(result.actual).equal(2);
        expect(result.plan).equal(6);
        expect(result.variance).equal(2 - 6);
      });

      it('responds to changes in conversionForecast', function() {
        getModel(app.conversionForecast).set({ value: 9 });

        result = app.reach.get('channel1', 'last-month');
        expect(result.actual).equal(1);
        expect(result.plan).equal(9);
        expect(result.variance).equal(1 - 9);
      });
    });
  });

  describe('channel reach', function() {
    beforeEach(function() { channel = app.channels.get('channel1') });

    describe('get', function() {
      it('calculates values for a single period', function() {
        result = channel.reach('last-month');
        expect(result.actual).equal(1);
        expect(result.plan).equal(6);
        expect(result.variance).equal(1 - 6);
      });

      it('contains no "actuals" for a future month', function() {
        result = channel.reach('next-month');
        expect(result.actual).undefined;
        expect(result.plan).equal(10);
        expect(result.variance).undefined;
      });

      it('returns an array of objects (all periods) by default', function() {
        result = channel.reach();
        expect(_.isArray(result)).true;
        expect(_.size(result)).equal(4);
        expect(result[1].get('period_id')).equal('last-month');
        expect(result[1].get('actual')).equal(1);
        expect(result[1].get('plan')).equal(6);
        expect(result[1].get('variance')).equal(1 - 6);
      });
    });

    describe('observers', function() {
      it('responds to changes in conversionSummary', function() {
        getModel(app.conversionSummary).set({ customer_volume: 2 });

        result = channel.reach('last-month');
        expect(result.actual).equal(2);
        expect(result.plan).equal(6);
        expect(result.variance).equal(2 - 6);
      });

      it('responds to changes in conversionForecast', function() {
        getModel(app.conversionForecast).set({ value: 9 });

        result = channel.reach('last-month');
        expect(result.actual).equal(1);
        expect(result.plan).equal(9);
        expect(result.variance).equal(1 - 9);
      });
    });
  });

  function getModel(collection) {
    var prevItem = app.reach.get('channel1', 'last-month');
    expect(prevItem.get('actual')).equal(1); // force calculations

    return collection.findWhere({
      period_id: 'last-month', stage_id: 'topline', channel_id: 'channel1'
    });
  }
});
