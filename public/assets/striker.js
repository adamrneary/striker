(function() {
  var Striker, schemaMap,
  __slice = [].slice;

Striker = void 0;

if (typeof exports !== 'undefined') {
  Striker = exports;
} else {
  Striker = window.Striker = {};
}

Striker.VERSION = '0.3.2';

schemaMap = function() {
  throw new Error('Setup your striker mapping with Striker.setSchemaMap');
};

Striker.setSchemaMap = function(cb) {
  return schemaMap = cb;
};

Striker.index = {};

Striker.Collection = (function() {
  _.extend(Collection.prototype, Backbone.Events);

  Collection.prototype.multiplier = 1;

  Collection.prototype.timeSeriesIdentifier = 'period_id';

  Collection.prototype.schema = [];

  Collection.prototype.observers = {};

  function Collection(options) {
    if (options == null) {
      options = {};
    }
    this.inputs = options.inputs || [];
    this.collections = _.map(this.schema, schemaMap);
    this.values = this._initValues();
    this._enableObserversAndBuild();
  }

  Collection.prototype.calculate = function() {
    var args;

    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  };

  Collection.prototype.isTimeSeries = function() {
    return _.last(this.schema) === this.timeSeriesIdentifier;
  };

  Collection.prototype.get = function() {
    var args, key, result, _i, _len;

    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    result = this.values;
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      key = args[_i];
      result = result[key];
    }
    if (_.isNumber(result)) {
      result = result / this.multiplier;
    }
    return result;
  };

  Collection.prototype.set = function() {
    var args, key, result, value, _i, _len, _ref;

    value = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    result = this.values;
    _ref = args.slice(0, -1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      result = result[key];
    }
    result[_.last(args)] = value;
    return this.trigger('change', this, args, value);
  };

  Collection.prototype.update = function() {
    var args;

    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.set.apply(this, [this.calculate.apply(this, args)].concat(__slice.call(args)));
  };

  Collection.prototype.flat = function(level, args, result) {
    var index, item, object, value, _i, _j, _len, _len1, _ref;

    if (level == null) {
      level = 0;
    }
    if (args == null) {
      args = [];
    }
    if (result == null) {
      result = [];
    }
    _ref = this.collections[level];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      args[level] = item.id;
      if (level < this.schema.length - 1) {
        this.flat(level + 1, args, result);
      } else {
        object = {};
        for (index = _j = 0, _len1 = args.length; _j < _len1; index = ++_j) {
          value = args[index];
          object[this.schema[index]] = value;
        }
        result.push(_.extend(object, this.get.apply(this, args)));
      }
    }
    return result;
  };

  Collection.prototype._enableObserversAndBuild = function() {
    var callback, collection, collectionName, _ref;

    _ref = this.observers;
    for (collectionName in _ref) {
      callback = _ref[collectionName];
      collection = collectionName === 'this' ? this : app[collectionName];
      collection.on('change', this._wrapCallback(callback), this);
    }
    return this._build();
  };

  Collection.prototype._initValues = function(values, inputs, level) {
    var item, order, value, _i, _len, _ref, _ref1;

    if (values == null) {
      values = {};
    }
    if (inputs == null) {
      inputs = this.inputs;
    }
    if (level == null) {
      level = 0;
    }
    if (this.collections[level]) {
      _ref = this.collections[level];
      for (order = _i = 0, _len = _ref.length; _i < _len; order = ++_i) {
        item = _ref[order];
        value = (_ref1 = inputs[order]) != null ? _ref1 : 0;
        if (this.schema) {
          if (level === this.schema.length - 1) {
            values[item.id] = value;
          } else {
            values[item.id] = {};
            this._initValues(values[item.id], value, level + 1);
          }
        }
      }
    }
    return values;
  };

  Collection.prototype._build = function(level, args) {
    var item, _i, _len, _ref, _results;

    if (level == null) {
      level = 0;
    }
    if (args == null) {
      args = [];
    }
    _ref = this.collections[level];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      args[level] = item.id;
      if (level >= this.schema.length - 1) {
        _results.push(this.update.apply(this, args));
      } else {
        _results.push(this._build(level + 1, args));
      }
    }
    return _results;
  };

  Collection.prototype._wrapCallback = function(defaultCallback) {
    return function(model, args, value) {
      if (model instanceof Backbone.Model) {
        return defaultCallback.call(this, model, model.changed);
      } else {
        return defaultCallback.call(this, model, args, value);
      }
    };
  };

  return Collection;

})();

Striker.addAnalysis = function(Model, methodName, options) {
  if (options == null) {
    options = {};
  }
  return Model.prototype[methodName] = function() {
    var analysis, args, _ref;

    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    analysis = app[(_ref = options.analysis) != null ? _ref : methodName];
    if (args.length > 0) {
      return analysis.get.apply(analysis, [this.id].concat(__slice.call(args)));
    } else {
      return analysis.flat(1, [this.id]);
    }
  };
};

Striker.setIndex = function(collectionName, schema) {
  var index;

  index = app[collectionName].groupBy(function(item) {
    return _.map(schema, function(key) {
      return item.get(key);
    });
  });
  return Striker.index[collectionName] = index;
};

Striker.where = function(collectionName, attrs) {
  var key, _ref;

  if (Striker.index[collectionName]) {
    key = _.values(attrs).join();
    return (_ref = Striker.index[collectionName][key]) != null ? _ref : [];
  } else {
    return app[collectionName].where(attrs);
  }
};

Striker.sum = function(array, field) {
  return _.reduce(array, function(memo, item) {
    return memo += item.get(field);
  }, 0);
};

}).call(this);

