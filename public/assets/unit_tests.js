(function() {
  var Accounts, CustomerRevenue, Customers, FinancialSummary, Periods;

CustomerRevenue = require('examples/strikers/customer_revenue');

Accounts = require('examples/collections/accounts');

Periods = require('examples/collections/periods');

Customers = require('examples/collections/customers');

FinancialSummary = require('examples/collections/financial_summary');

describe('customer revenue', function() {
  beforeEach(function() {
    app.periods = new Periods([
      {
        id: 'last-month',
        first_day: '2012-01-01'
      }, {
        id: 'this-month',
        first_day: '2012-02-01'
      }, {
        id: 'next-month',
        first_day: '2012-03-01'
      }, {
        id: 'two-years-ago',
        first_day: '2010-02-01'
      }
    ]);
    app.accounts = new Accounts([
      {
        id: 'ast',
        type: 'Asset'
      }, {
        id: 'rev',
        type: 'Revenue'
      }, {
        id: 'rev2',
        type: 'Revenue'
      }, {
        id: 'exp',
        type: 'Expense'
      }
    ]);
    app.customers = new Customers([
      {
        id: 'customer1',
        channel_id: 'channel1',
        segment_id: 'segment1'
      }, {
        id: 'customer2',
        channel_id: 'channel1',
        segment_id: 'segment1'
      }, {
        id: 'customer3',
        channel_id: 'channel2',
        segment_id: 'segment2'
      }
    ]);
    app.financialSummary = new FinancialSummary([
      {
        period_id: 'last-month',
        account_id: 'rev',
        customer_id: 'customer1',
        amount_cents: 100
      }, {
        period_id: 'this-month',
        account_id: 'rev',
        customer_id: 'customer1',
        amount_cents: 100
      }, {
        period_id: 'this-month',
        account_id: 'ast',
        customer_id: 'customer1',
        amount_cents: 300
      }, {
        period_id: 'this-month',
        account_id: 'rev2',
        customer_id: 'customer1',
        amount_cents: 200
      }, {
        period_id: 'this-month',
        account_id: 'rev',
        customer_id: 'customer2',
        amount_cents: 123
      }, {
        period_id: 'this-month',
        account_id: 'rev',
        customer_id: 'customer3',
        amount_cents: 456
      }, {
        period_id: 'this-month',
        account_id: 'exp',
        customer_id: 'customer1',
        amount_cents: 200
      }
    ]);
    Striker.setIndex('financialSummary', ['period_id', 'customer_id', 'account_id']);
    return app.customerRevenue = new CustomerRevenue();
  });
  describe('overall revenue', function() {
    describe('get', function() {
      it('calculates values for a single customer and period', function() {
        var result;

        result = app.customerRevenue.get('customer1', 'this-month');
        expect(result.actual).equal(100 + 200);
        expect(result.plan).equal(void 0);
        return expect(result.variance).equal(void 0);
      });
      it('contains nothing for future months', function() {
        var result;

        result = app.customerRevenue.get('customer1', 'next-month');
        expect(result.actual).equal(void 0);
        expect(result.plan).equal(void 0);
        return expect(result.variance).equal(void 0);
      });
      it('returns an array of objects (all periods) by default', function() {
        var result;

        result = app.customerRevenue.flat();
        expect(_.isArray(result)).equal(true);
        expect(_.size(result)).equal(12);
        expect(result[0]['customer_id']).equal('customer1');
        expect(result[0]['period_id']).equal('last-month');
        expect(result[0]['actual']).equal(100);
        expect(result[0]['plan']).equal(void 0);
        expect(result[0]['variance']).equal(void 0);
        expect(result[1]['customer_id']).equal('customer1');
        expect(result[1]['period_id']).equal('this-month');
        expect(result[1]['actual']).equal(100 + 200);
        expect(result[1]['plan']).equal(void 0);
        return expect(result[1]['variance']).equal(void 0);
      });
      return it('returns object with all periods for customer', function() {
        var lastMonth, result;

        result = app.customerRevenue.get('customer1');
        expect(_.size(result)).equal(4);
        lastMonth = result['last-month'];
        expect(lastMonth.actual).equal(100);
        expect(lastMonth.plan).equal(void 0);
        return expect(lastMonth.variance).equal(void 0);
      });
    });
    return describe('triggers', function() {
      return it('responds to changes in financialSummary', function() {
        var model, result;

        model = app.financialSummary.findWhere({
          period_id: 'last-month',
          account_id: 'rev',
          customer_id: 'customer1'
        });
        model.set({
          amount_cents: 123
        });
        result = app.customerRevenue.get('customer1', 'last-month');
        return expect(result.actual).equal(123);
      });
    });
  });
  return describe('for customer', function() {
    beforeEach(function() {
      return this.customer = app.customers.get('customer1');
    });
    describe('get', function() {
      it('calculates values for a single period', function() {
        var result;

        result = this.customer.revenue('this-month');
        expect(result['actual']).equal(100 + 200);
        expect(result['plan']).equal(void 0);
        return expect(result['variance']).equal(void 0);
      });
      it('contains nothing for future months', function() {
        var result;

        result = this.customer.revenue('next-month');
        expect(result['actual']).equal(void 0);
        expect(result['plan']).equal(void 0);
        return expect(result['variance']).equal(void 0);
      });
      return it('returns an array of objects (all periods) by default', function() {
        var lastMonth, result;

        result = this.customer.revenue();
        expect(_.isArray(result)).equal(true);
        expect(_.size(result)).equal(4);
        lastMonth = result[0];
        expect(lastMonth.period_id).equal('last-month');
        expect(lastMonth.actual).equal(100);
        expect(lastMonth.plan).equal(void 0);
        return expect(lastMonth.variance).equal(void 0);
      });
    });
    return describe('triggers', function() {
      return it('responds to changes in financialSummary', function() {
        var model, result;

        model = app.financialSummary.findWhere({
          period_id: 'last-month',
          account_id: 'rev',
          customer_id: 'customer1'
        });
        model.set({
          amount_cents: 123
        });
        result = this.customer.revenue('last-month');
        return expect(result['actual']).equal(123);
      });
    });
  });
});

}).call(this);

(function() {
  var Channels, ConversionForecast, ConversionSummary, Periods, Reach, Stages;

Reach = require('examples/strikers/reach');

Periods = require('examples/collections/periods');

Channels = require('examples/collections/channels');

Stages = require('examples/collections/stages');

ConversionSummary = require('examples/collections/conversion_summary');

ConversionForecast = require('examples/collections/conversion_forecast');

describe('reach', function() {
  beforeEach(function() {
    app.periods = new Periods([
      {
        id: 'last-month',
        first_day: '2012-01-01T00:00:00.000Z'
      }, {
        id: 'this-month',
        first_day: '2012-02-01T00:00:00.000Z'
      }, {
        id: 'next-month',
        first_day: '2012-03-01T00:00:00.000Z'
      }, {
        id: 'two-years-ago',
        first_day: '2010-02-01T00:00:00.000Z'
      }
    ]);
    app.channels = new Channels([
      {
        id: 'channel1'
      }, {
        id: 'channel2'
      }
    ]);
    app.stages = new Stages([
      {
        id: 'topline',
        position: 2
      }, {
        id: 'customer',
        position: 1
      }
    ]);
    app.conversionSummary = new ConversionSummary([
      {
        period_id: 'last-month',
        stage_id: 'topline',
        channel_id: 'channel1',
        customer_volume: 1
      }, {
        period_id: 'last-month',
        stage_id: 'topline',
        channel_id: 'channel2',
        customer_volume: 2
      }, {
        period_id: 'this-month',
        stage_id: 'topline',
        channel_id: 'channel1',
        customer_volume: 3
      }, {
        period_id: 'this-month',
        stage_id: 'topline',
        channel_id: 'channel2',
        customer_volume: 4
      }, {
        period_id: 'this-month',
        stage_id: 'customer',
        channel_id: 'channel1',
        customer_volume: 5
      }
    ]);
    app.conversionForecast = new ConversionForecast([
      {
        period_id: 'last-month',
        channel_id: 'channel1',
        stage_id: 'topline',
        value: 6
      }, {
        period_id: 'last-month',
        channel_id: 'channel2',
        stage_id: 'topline',
        value: 7
      }, {
        period_id: 'this-month',
        channel_id: 'channel1',
        stage_id: 'topline',
        value: 8
      }, {
        period_id: 'this-month',
        channel_id: 'channel2',
        stage_id: 'topline',
        value: 9
      }, {
        period_id: 'next-month',
        channel_id: 'channel1',
        stage_id: 'topline',
        value: 10
      }, {
        period_id: 'next-month',
        channel_id: 'channel2',
        stage_id: 'topline',
        value: 11
      }, {
        period_id: 'this-month',
        channel_id: 'channel1',
        stage_id: 'customer',
        value: 12
      }
    ]);
    Striker.setIndex('conversionForecast', ['stage_id', 'channel_id', 'period_id']);
    Striker.setIndex('conversionSummary', ['stage_id', 'channel_id', 'period_id']);
    return app.reach = new Reach();
  });
  describe('overall', function() {
    describe('get', function() {
      it('calculates values for a single channel and period', function() {
        var result;

        result = app.reach.get('channel1', 'last-month');
        expect(result['actual']).equal(1);
        expect(result['plan']).equal(6);
        return expect(result['variance']).equal(1 - 6);
      });
      it('contains no "actual" or "variance" for future months', function() {
        var result;

        result = app.reach.get('channel1', 'next-month');
        expect(result['actual']).equal(void 0);
        expect(result['plan']).equal(10);
        return expect(result['variance']).equal(void 0);
      });
      return it('returns an array of objects (all periods) by default', function() {
        var result;

        result = app.reach.flat();
        expect(_.isArray(result)).equal(true);
        expect(_.size(result)).equal(8);
        expect(result[0]['channel_id']).equal('channel1');
        expect(result[0]['period_id']).equal('last-month');
        expect(result[0]['actual']).equal(1);
        expect(result[0]['plan']).equal(6);
        return expect(result[0]['variance']).equal(1 - 6);
      });
    });
    return describe('triggers', function() {
      it('responds to changes in conversionSummary', function() {
        var model, result;

        model = app.conversionSummary.findWhere({
          period_id: 'last-month',
          stage_id: 'topline',
          channel_id: 'channel1'
        });
        model.set({
          customer_volume: 2
        });
        result = app.reach.get('channel1', 'last-month');
        expect(result['actual']).equal(2);
        expect(result['plan']).equal(6);
        return expect(result['variance']).equal(2 - 6);
      });
      return it('responds to changes in conversionForecast', function() {
        var model, result;

        model = app.conversionForecast.findWhere({
          period_id: 'last-month',
          stage_id: 'topline',
          channel_id: 'channel1'
        });
        model.set({
          value: 9
        });
        result = app.reach.get('channel1', 'last-month');
        expect(result['actual']).equal(1);
        expect(result['plan']).equal(9);
        return expect(result['variance']).equal(1 - 9);
      });
    });
  });
  return describe('channel reach', function() {
    beforeEach(function() {
      return this.channel = app.channels.get('channel1');
    });
    describe('get', function() {
      it('calculates values for a single period', function() {
        var result;

        result = this.channel.reach('last-month');
        expect(result['actual']).equal(1);
        expect(result['plan']).equal(6);
        return expect(result['variance']).equal(1 - 6);
      });
      it('contains no "actuals" for a future month', function() {
        var result;

        result = this.channel.reach('next-month');
        expect(result['actual']).equal(void 0);
        expect(result['plan']).equal(10);
        return expect(result['variance']).equal(void 0);
      });
      return it('returns an array of objects (all periods) by default', function() {
        var result;

        result = this.channel.reach();
        expect(_.isArray(result)).equal(true);
        expect(_.size(result)).equal(4);
        expect(result[0]['period_id']).equal('last-month');
        expect(result[0]['actual']).equal(1);
        expect(result[0]['plan']).equal(6);
        return expect(result[0]['variance']).equal(1 - 6);
      });
    });
    return describe('triggers', function() {
      it('responds to changes in conversionSummary', function() {
        var model, result;

        model = app.conversionSummary.findWhere({
          period_id: 'last-month',
          stage_id: 'topline',
          channel_id: 'channel1'
        });
        model.set({
          customer_volume: 2
        });
        result = this.channel.reach('last-month');
        expect(result['actual']).equal(2);
        expect(result['plan']).equal(6);
        return expect(result['variance']).equal(2 - 6);
      });
      return it('responds to changes in conversionForecast', function() {
        var model, result;

        model = app.conversionForecast.findWhere({
          period_id: 'last-month',
          stage_id: 'topline',
          channel_id: 'channel1'
        });
        model.set({
          value: 9
        });
        result = this.channel.reach('last-month');
        expect(result['actual']).equal(1);
        expect(result['plan']).equal(9);
        return expect(result['variance']).equal(1 - 9);
      });
    });
  });
});

}).call(this);

(function() {
  var Periods;

window.expect = chai.expect;

mocha.setup({
  globals: ['app']
});

Periods = require('examples/collections/periods');

Periods.prototype.compare = function(date1, date2) {
  return new Date(date1).getTime() > new Date('2012-02-14T14:25:30.000Z').getTime();
};

Striker.setSchemaMap(function(key) {
  switch (key) {
    case 'channel_id':
      return app.channels.models;
    case 'customer_id':
      return app.customers.models;
    case 'period_id':
      return app.periods.models;
  }
});

beforeEach(function() {
  return window.app = {};
});

}).call(this);

(function() {
  describe('Striker', function() {
  return it('exists', function() {
    expect(Striker).exists;
    return expect(Striker.Collection).exists;
  });
});

}).call(this);

