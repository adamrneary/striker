(function() {
  var init;

init = function(name, options) {
  var Collection;

  if (options == null) {
    options = {};
  }
  Collection = require("examples/" + name);
  return new Collection(options);
};

$(function() {
  if (typeof mocha !== 'undefined') {
    return;
  }
  if (!_.include(['/', '/performance'], location.pathname)) {
    return;
  }
  window.app = {};
  app.periods = init('collections/periods', [
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
  app.accounts = init('collections/accounts', [
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
  app.customers = init('collections/customers', [
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
  app.channels = init('collections/channels', [
    {
      id: 'channel1',
      name: 'Channel 1'
    }, {
      id: 'channel2',
      name: 'Channel 2'
    }
  ]);
  app.stages = init('collections/stages', [
    {
      id: 'topline',
      position: 2,
      name: 'Stage 1 (Topline)'
    }, {
      id: 'customer',
      position: 1,
      name: 'Stage 3 (Customer)'
    }
  ]);
  app.conversionSummary = init('collections/conversion_summary', [
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
  app.conversionForecast = init('collections/conversion_forecast', [
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
  app.financialSummary = init('collections/financial_summary', [
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
  Striker.setIndex('conversionForecast', ['stage_id', 'channel_id', 'period_id']);
  Striker.setIndex('conversionSummary', ['stage_id', 'channel_id', 'period_id']);
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
  app.reach = init('strikers/reach');
  app.customerRevenue = init('strikers/customer_revenue');
  switch (location.pathname) {
    case '/':
      return new init('views/index').render();
    case '/performance':
      return new init('views/performance');
  }
});

}).call(this);

require.define({"examples/collections/accounts": function(exports, require, module) {
  var Accounts, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = Accounts = (function(_super) {
  __extends(Accounts, _super);

  function Accounts() {
    _ref = Accounts.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Accounts.prototype.revenue = function() {
    return this.where({
      type: 'Revenue'
    });
  };

  return Accounts;

})(Backbone.Collection);

}});

require.define({"examples/collections/channels": function(exports, require, module) {
  var Channel, Channels, _ref, _ref1,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Channel = (function(_super) {
  __extends(Channel, _super);

  function Channel() {
    _ref = Channel.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  return Channel;

})(Backbone.Model);

Striker.addAnalysis(Channel, 'reach');

module.exports = Channels = (function(_super) {
  __extends(Channels, _super);

  function Channels() {
    _ref1 = Channels.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  Channels.prototype.model = Channel;

  Channels.prototype.toplineId = function() {
    return 'topline';
  };

  return Channels;

})(Backbone.Collection);

}});

require.define({"examples/collections/conversion_forecast": function(exports, require, module) {
  var ConversionForecast, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = ConversionForecast = (function(_super) {
  __extends(ConversionForecast, _super);

  function ConversionForecast() {
    _ref = ConversionForecast.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  return ConversionForecast;

})(Backbone.Collection);

}});

require.define({"examples/collections/conversion_summary": function(exports, require, module) {
  var ConversionSummary, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = ConversionSummary = (function(_super) {
  __extends(ConversionSummary, _super);

  function ConversionSummary() {
    _ref = ConversionSummary.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  return ConversionSummary;

})(Backbone.Collection);

}});

require.define({"examples/collections/customers": function(exports, require, module) {
  var Customer, Customers, _ref, _ref1,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Customer = (function(_super) {
  __extends(Customer, _super);

  function Customer() {
    _ref = Customer.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  return Customer;

})(Backbone.Model);

Striker.addAnalysis(Customer, 'revenue', {
  analysis: 'customerRevenue'
});

module.exports = Customers = (function(_super) {
  __extends(Customers, _super);

  function Customers() {
    _ref1 = Customers.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  Customers.prototype.model = Customer;

  return Customers;

})(Backbone.Collection);

}});

require.define({"examples/collections/financial_summary": function(exports, require, module) {
  var FinancialSummary, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = FinancialSummary = (function(_super) {
  __extends(FinancialSummary, _super);

  function FinancialSummary() {
    _ref = FinancialSummary.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  return FinancialSummary;

})(Backbone.Collection);

}});

require.define({"examples/collections/periods": function(exports, require, module) {
  var Periods, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = Periods = (function(_super) {
  __extends(Periods, _super);

  function Periods() {
    _ref = Periods.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Periods.prototype.isFuture = function(periodId) {
    var firstDay;

    firstDay = this.get(periodId).get('first_day');
    return this.compare(new Date(firstDay), new Date());
  };

  Periods.prototype.compare = function(date1, date2) {
    return date1.getTime() - 1 > date2.getTime();
  };

  return Periods;

})(Backbone.Collection);

}});

require.define({"examples/collections/stages": function(exports, require, module) {
  var Stages, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = Stages = (function(_super) {
  __extends(Stages, _super);

  function Stages() {
    _ref = Stages.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  return Stages;

})(Backbone.Collection);

}});

require.define({"examples/strikers/customer_revenue": function(exports, require, module) {
  var Revenue, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = Revenue = (function(_super) {
  __extends(Revenue, _super);

  function Revenue() {
    _ref = Revenue.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Revenue.prototype.schema = ['customer_id', 'period_id'];

  Revenue.prototype.observers = {
    financialSummary: function(model, changed) {
      if (!_.include(_.pluck(app.accounts.revenue(), 'id'), model.get('account_id'))) {
        return;
      }
      if (_.has(changed, 'amount_cents')) {
        return this.update(model.get('customer_id'), model.get('period_id'));
      }
    }
  };

  Revenue.prototype.calculate = function(customerId, periodId) {
    var object, summaries;

    summaries = _.map(_.pluck(app.accounts.revenue(), 'id'), function(accountId) {
      return Striker.where('financialSummary', {
        period_id: periodId,
        customer_id: customerId,
        account_id: accountId
      });
    });
    summaries = _.flatten(summaries);
    object = {};
    if (!_.isEmpty(summaries)) {
      object.actual = Striker.sum(summaries, 'amount_cents');
    }
    return object;
  };

  return Revenue;

})(Striker.Collection);

}});

require.define({"examples/strikers/reach": function(exports, require, module) {
  var Reach, observer, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

observer = function(value) {
  return function(model, changed) {
    var toplineId;

    toplineId = app.channels.toplineId();
    if (model.get('stage_id') !== toplineId) {
      return;
    }
    if (_.has(changed, value)) {
      return this.update(model.get('channel_id'), model.get('period_id'));
    }
  };
};

module.exports = Reach = (function(_super) {
  __extends(Reach, _super);

  function Reach() {
    _ref = Reach.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Reach.prototype.schema = ['channel_id', 'period_id'];

  Reach.prototype.observers = {
    conversionSummary: observer('customer_volume'),
    conversionForecast: observer('value')
  };

  Reach.prototype.calculate = function(channelId, periodId) {
    var conversionForecast, conversionSummary, isFuture, result, toplineId;

    toplineId = app.channels.toplineId();
    isFuture = app.periods.isFuture(periodId);
    conversionSummary = Striker.where('conversionSummary', {
      stage_id: toplineId,
      channel_id: channelId,
      period_id: periodId
    });
    conversionForecast = Striker.where('conversionForecast', {
      stage_id: toplineId,
      channel_id: channelId,
      period_id: periodId
    });
    result = {};
    if (!isFuture) {
      result.actual = Striker.sum(conversionSummary, 'customer_volume');
    }
    result.plan = Striker.sum(conversionForecast, 'value');
    if (!isFuture) {
      result.variance = result.actual - result.plan;
    }
    return result;
  };

  return Reach;

})(Striker.Collection);

}});

require.define({"examples/views/index": function(exports, require, module) {
  var IndexView, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = IndexView = (function(_super) {
  __extends(IndexView, _super);

  function IndexView() {
    this.changeRow = __bind(this.changeRow, this);    _ref = IndexView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  IndexView.prototype.el = '#container';

  IndexView.prototype.monthCount = 36;

  IndexView.prototype.columns = {
    streams: [
      {
        id: "id",
        label: "ID",
        classes: "row-heading"
      }, {
        id: "name",
        label: "Name"
      }
    ],
    segments: [
      {
        id: "id",
        label: "ID",
        classes: "row-heading"
      }, {
        id: "name",
        label: "Name"
      }
    ],
    channels: [
      {
        id: "id",
        label: "ID",
        classes: "row-heading"
      }, {
        id: "name",
        label: "Name"
      }
    ],
    stages: [
      {
        id: "id",
        label: "ID",
        classes: "row-heading"
      }, {
        id: "name",
        label: "Name"
      }, {
        id: "lag",
        label: "Lag"
      }, {
        id: "is_topline",
        label: "Is topline"
      }, {
        id: "is_customer",
        label: "Is customer"
      }
    ],
    channelSegmentMix: [
      {
        id: "channelId",
        label: "Channel id",
        classes: "row-heading"
      }, {
        id: "segmentId",
        label: "Segment id",
        classes: "row-heading"
      }, {
        id: "value",
        label: "Value"
      }
    ],
    initialVolume: [
      {
        id: "stageId",
        label: "Stage id",
        classes: "row-heading"
      }, {
        id: "channelId",
        label: "Channel id",
        classes: "row-heading"
      }, {
        id: "segmentId",
        label: "Segment id",
        classes: "row-heading"
      }, {
        id: "value",
        label: "Value"
      }
    ],
    toplineGrowth: [
      {
        id: "channelId",
        label: "Channel id",
        classes: "row-heading",
        width: '70px'
      }
    ],
    conversionRates: [
      {
        id: "stageId",
        label: "Stage id",
        classes: "row-heading",
        width: '70px'
      }, {
        id: "channelId",
        label: "Channel id",
        classes: "row-heading",
        width: '70px'
      }
    ],
    churnRates: [
      {
        id: "segmentId",
        label: "Segment id",
        classes: "row-heading",
        width: '70px'
      }
    ],
    conversionForecast: [
      {
        id: "stageId",
        label: "Stage id",
        classes: "row-heading",
        width: '70px'
      }, {
        id: "segmentId",
        label: "Segment id",
        classes: "row-heading",
        width: '70px'
      }, {
        id: "channelId",
        label: "Channel id",
        classes: "row-heading",
        width: '70px'
      }
    ],
    customerForecast: [
      {
        id: "channelId",
        label: "Channel id",
        classes: "row-heading",
        width: '70px'
      }, {
        id: "segmentId",
        label: "Segment id",
        classes: "row-heading",
        width: '70px'
      }
    ],
    churnForecast: [
      {
        id: "channelId",
        label: "Channel id",
        classes: "row-heading",
        width: '70px'
      }, {
        id: "segmentId",
        label: "Segment id",
        classes: "row-heading",
        width: '70px'
      }
    ]
  };

  IndexView.prototype.render = function() {
    this._renderInputs();
    this._renderForecasts();
    return this;
  };

  IndexView.prototype._renderInputs = function() {
    var input, _i, _j, _len, _len1, _ref1, _ref2, _results;

    _ref1 = ['streams', 'segments', 'channels', 'stages'];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      input = _ref1[_i];
      this._renderBackboneCollection(input);
    }
    _ref2 = ['channelSegmentMix', 'initialVolume', 'toplineGrowth', 'conversionRates', 'churnRates'];
    _results = [];
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      input = _ref2[_j];
      _results.push(this._renderStrikerCollection(input));
    }
    return _results;
  };

  IndexView.prototype._renderBackboneCollection = function(name) {
    var grid;

    return grid = new window.TableStakes().el("#" + name).columns(this.columns[name]).data(app[name].toJSON()).render();
  };

  IndexView.prototype._renderStrikerCollection = function(name) {
    var columns, grid;

    columns = this.columns[name];
    if (app[name].isTimeSeries()) {
      columns = this._addMonths(columns);
    }
    return grid = new window.TableStakes().el("#" + name).columns(columns).data(app[name].toArray()).render();
  };

  IndexView.prototype._addMonths = function(columns) {
    var _this = this;

    _.times(this.monthCount, function(i) {
      return columns.push({
        id: i,
        label: "" + (i + 1)
      });
    });
    return columns;
  };

  IndexView.prototype._renderForecasts = function() {
    var forecast, _i, _len, _ref1, _results;

    new App.Views.HighChart().render();
    _ref1 = ['conversionForecast', 'churnForecast', 'customerForecast'];
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      forecast = _ref1[_i];
      _results.push(this._renderStrikerCollection(forecast));
    }
    return _results;
  };

  IndexView.prototype.highlight = function() {
    return $('.channelSegmentMix td:last-child,\n.initialVolume td:last-child,\n.toplineGrowth td:not(:first-child),\n.conversionRates td:not(:first-child, :nth-child(2)),\n.churnRates td:not(:first-child)').addClass('yellow');
  };

  IndexView.prototype.makeInteractive = function(collection) {
    var dopSelector;

    collection.on('change', this.changeRow);
    dopSelector = collection.isTimeSeries() ? ':not(:first)' : '';
    return $("." + collection.name + " tr:not(:first)" + dopSelector).each(function() {
      var $tr, args, field, notPart, order, _i, _len, _ref1, _ref2;

      _ref1 = [$(this), {}, ''], $tr = _ref1[0], args = _ref1[1], notPart = _ref1[2];
      _ref2 = collection.schema;
      for (order = _i = 0, _len = _ref2.length; _i < _len; order = ++_i) {
        field = _ref2[order];
        if (order > 0) {
          notPart += ':not(:first)';
        }
        args[field] = $tr.find("td" + notPart + ":first").html();
      }
      if (!collection.isTimeSeries()) {
        notPart += ':not(:first)';
      }
      return $tr.find("td" + notPart).each(function(order) {
        var $td, key, value;

        $td = $(this);
        for (key in args) {
          value = args[key];
          $td.attr(key, value);
        }
        if (collection.isTimeSeries()) {
          return $td.attr('monthId', order + 1);
        }
      });
    });
  };

  IndexView.prototype.changeRow = function(args, value, collection) {
    var field, order, selector, _i, _len, _ref1;

    selector = '';
    _ref1 = collection.schema;
    for (order = _i = 0, _len = _ref1.length; _i < _len; order = ++_i) {
      field = _ref1[order];
      selector += "[" + field + "=" + args[order] + "]";
    }
    $("table." + collection.name + " tbody tr td" + selector + ":first").html(value);
    return this.renderForecasts();
  };

  return IndexView;

})(Backbone.View);

}});

require.define({"examples/views/performance": function(exports, require, module) {
  var PerformanceView, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

module.exports = PerformanceView = (function(_super) {
  __extends(PerformanceView, _super);

  function PerformanceView() {
    _ref = PerformanceView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  PerformanceView.prototype.el = '#container';

  PerformanceView.prototype.printTemplate = _.template('<b>Local sets: </b><%= striker.localSetCounter %>\n<b>Local gets: </b><%= striker.localGetCounter %>\n<hr>\n<b>Min time: </b><%= _(times).min() %>ms\n<b>Max time: </b><%= _(times).max() %>ms\n<b>Avr time: </b><%= average %>ms\n<hr>\n<b>Total time: </b><%= time %>ms');

  PerformanceView.prototype.events = {
    'submit': 'runRandomizeTest',
    'click .clear': 'clear'
  };

  PerformanceView.prototype.initialize = function() {
    return $('li.test_data').addClass('active');
  };

  PerformanceView.prototype.runRandomizeTest = function(event) {
    var count, eventsLog, id, startTime, striker;

    event.preventDefault();
    id = event.target.id;
    count = parseInt(this.$("#" + id + "Input").val());
    striker = app[id];
    startTime = (new Date).getTime();
    eventsLog = [];
    this.addCounters(striker);
    this.runTestsFor(striker, eventsLog, count);
    return this.printResults(id, count, striker, startTime, eventsLog);
  };

  PerformanceView.prototype.printResults = function(id, count, striker, startTime, eventsLog) {
    var time;

    time = (new Date).getTime() - startTime;
    return this.$("#" + id + "Results").html(this.printTemplate({
      count: count,
      time: time,
      striker: striker,
      average: time / count,
      times: _(eventsLog).pluck('time')
    }));
  };

  PerformanceView.prototype.clear = function(event) {
    var id;

    event.preventDefault();
    id = $(event.target).attr('data-id');
    return this.$("#" + id + "Results").html('No results');
  };

  PerformanceView.prototype.addCounters = function(striker) {
    var _ref1;

    if (!striker.defaultSet) {
      striker.defaultSet = striker.set;
    }
    if (!striker.defaultGet) {
      striker.defaultGet = striker.get;
    }
    _ref1 = [0, 0], striker.localSetCounter = _ref1[0], striker.localGetCounter = _ref1[1];
    striker.set = function() {
      var args, value;

      value = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.localSetCounter += 1;
      return this.defaultSet.apply(this, [value].concat(__slice.call(args)));
    };
    return striker.get = function() {
      var args;

      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.localGetCounter += 1;
      return this.defaultGet.apply(this, args);
    };
  };

  PerformanceView.prototype.runTestsFor = function(striker, eventsLog, count) {
    var _this = this;

    return _(count).times(function() {
      var collection, field, model, position, time, value, _ref1;

      time = (new Date).getTime();
      value = _.random(0, 100);
      _ref1 = striker.constructor.name === 'Revenue' ? [app.financialSummary, 'amount_cents'] : [[app.conversionSummary, 'customer_volume'], [app.conversionForecast, 'value']][_.random(0, 1)], collection = _ref1[0], field = _ref1[1];
      position = _.random(0, collection.length - 1);
      model = collection.at(position);
      model.set(field, value);
      return eventsLog.push({
        value: value,
        time: (new Date).getTime() - time
      });
    });
  };

  return PerformanceView;

})(Backbone.View);

}});

