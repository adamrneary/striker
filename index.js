;(function(_, Backbone) {
'use strict';

/**
 * Define `Striker` constructor
 */

function Striker(options) {
  if (!options) options = {};
  if (options.stat) this._initStat();

  this.Entry = Entry.extend({});
  this._initCollections();
  this._reset();
  this._defineCustomAttributes();
  this._enableObservers(options);
}

// Apply EventEmitter pattern and set default values
_.extend(Striker.prototype, Backbone.Events, {
  // Array with collection IDs which map with Striker.schemaMap
  schema: [],

  // Observers and event handling
  observers: {},

  // optional list of getters, by default striker calculate it automatically,
  // based on calculate output
  getters: [],

  // Raw method to calculate value, it calls on every `update`
  // Override it with striker's specific calculations
  calculate: function() { return {} },
});

// Convenient method to get one value based on schema
Striker.prototype.get = function() {
  var args   = _.toArray(arguments);
  var result = this.values;

  for (var i = 0, len = args.length; i < len; i++) {
    if (!result) break;
    result = result[args[i]];
  }

  return result;
};

Striker.prototype.reverseValues = function() {
  var result    = {};
  var schema    = _.clone(this.schema).reverse();
  var schemaLen = schema.length;

  for (var i = 0, len = this.entries.length, entry, item; i < len; i++) {
    entry = this.entries[i];
    item  = result;
    for (var j = 0, schemaId, value; j < schemaLen; j++) {
      schemaId = schema[j];
      value    = entry.attributes[schemaId];
      if (!item[value]) item[value] = {};
      j + 1 === schemaLen ? (item[value] = entry) : (item = item[value]);
    }
  }

  return result;
};

// Convenient method to trigger `change` event and force lazy calculations
Striker.prototype.update = function() {
  var entry = this.get.apply(this, arguments);
  if (entry && !entry.isLazy) {
    this.trigger('change', entry, _.toArray(arguments));
    entry.isLazy = true;
  }
};

Striker.prototype._reset = function() {
  this.values  = {};
  this.entries = [];
  this._initEntries(this.values, {}, 0);
};

// Enable collections observers for `add`&`remove` events
Striker.prototype._initCollections = function() {
  this.collections = this.schema.map(Striker.schemaMap);
  this.schema.forEach(function(key, index) {
    var coll = _.first(this.collections[index]).collection;

    // reset is simpler than rebuild this.{values|entries} correctly
    coll.on('remove', this._reset, this);
    coll.on('add', this._reset, this);
  }, this);
};

// Initialize entries based on schema
Striker.prototype._initEntries = function(values, item, level) {
  var key    = this.schema[level];
  var models = this.collections[level];

  for (var i = 0, len = models.length, modelId; i < len; i++) {
    modelId   = models[i].id;
    item[key] = modelId;
    if (this.collections.length === level + 1) {
      var entry = new this.Entry(item, this);
      values[modelId] = entry;
      this.entries.push(entry);
    } else {
      values[modelId] = {};
      this._initEntries(values[modelId], item, level + 1);
    }
  }
};

// Setup collection observers based on `this.observers`
// Name `this` uses for self reference
//
// For strikers that trigger themselves
// we need to enable triggers before any values are calculated.
Striker.prototype._enableObservers = function(options) {
  if (_.isEmpty(this.observers)) return;
  if (options.careful && this.observers.this) options.careful = false;

  var that = this;
  function enableObservers() {
    _.each(that.observers, function(callback, name) {
      var collection = name === 'this' ? that : Striker.namespace[name];

      collection.on('change', function(model, attrs) {
        if (_.isUndefined(model)) return;
        if (model instanceof Backbone.Model)
          callback.call(that, model, model.changedAttributes());
        else
          callback.call(that, model, attrs);
        that.trigger('updateCompleted', model);
      });
    });
  }

  options.careful ?
    Striker.once('enable-observers', enableObservers) :
    enableObservers();
};

// An ES5 magic:
// in order to define nice API and avoid constant `get`,
// we define CustomEntry for every striker, which contains necessary getters
// based on first not lazy calculation
Striker.prototype._defineCustomAttributes = function() {
  var proto = this.Entry.prototype;

  if (_.isEmpty(this.getters)) {
    var entry    = _.first(this.entries);
    this.getters = _.uniq(Object.keys(entry.all()));
  }

  this.getters.forEach(function(name) {
    Object.defineProperty(proto, name, {
      get: function() { return this.get(name) } // proxy to Entry#get()
    });
  });
};

// Special mode to debug strikers.
// IMPORTANT: don't use it in production, only for development
// it works only in google chrome, because it has performance.now()
// Main problem for strikers is a slow `calculate` method, and often observers calls.
var statistics = {};

Striker.prototype._initStat = function() {
  var name      = this.name || this.constructor.name;
  var calculate = this.calculate;
  var stat      = statistics[name] || [];

  statistics[name] = stat;
  function now() {
    return typeof performance === 'undefined' ? Date.now() : performance.now();
  }

  this.calculate = function() {
    var start  = now();
    var result = calculate.apply(this, arguments);

    stat.push({
      type: 'calculate',
      time: now() - start,
      args: _.toArray(arguments)
    });

    return result;
  };
};

// Apply methods of Backbone.Index - where, query
Backbone.Index(Striker, { ignoreChange: true });

// Apply relevant underscore's methods
var methods = ['forEach', 'map', 'reduce', 'reduceRight', 'find', 'filter',
  'every', 'some', 'include', 'invoke', 'groupBy', 'countBy', 'sortBy',
  'max', 'min', 'size', 'indexOf', 'isEmpty'];

// Mix in each Underscore method as a proxy to `striker#entries`.
_.each(methods, function(method) {
  Striker.prototype[method] = function() {
    var args = _.toArray(arguments);
    args.unshift(this.entries);
    return _[method].apply(_, args);
  };
});

/**
 * Static methods
 */

// use Striker object to notify existing strikers
_.extend(Striker, Backbone.Events);

// Add striker(analysis) to Backbone.Model
Striker.addAnalysis = function(Model, methodName, options) {
  if (!options) options = {};
  Model.prototype[methodName] = function() {
    var striker = Striker.namespace[options.analysis || methodName];
    var args    = _.toArray(arguments);

    if (args.length > 0) {
      return striker.get.apply(striker, [this.id].concat(args));
    } else {
      var attrs = _.object([[_.first(striker.schema), this.id]]);
      return striker.where(attrs);
    }
  };
};

// Setup schema mapping, to transform keys to real models
Striker.schemaMap = function() {
  throw new Error('CRITICAL: Override this');
};

// Show statistics
Striker.stat = function() {
  _.forEach(statistics, function(values, name) {
    var time  = _.pluck(values, 'time');
    var total = values.length;
    var sum   = _.sum(time);
    var avr   = sum / total;
    var color = total > 10 && avr > 0.6 ? (avr > 1 ? 'red' : 'purple') : 'black';

    console.log('%c%s: total %d, average %sms, time %sms',
      'color: ' + color, name, total, avr.toFixed(2), sum.toFixed(2));
  });
};

// Define default namespace for observers
Striker.namespace = window;

/**
 * Define `Entry`
 * It uses to perform lazy evaluations
 */

function Entry(attrs, striker) {
  this.attributes = _.clone(attrs);
  this.collection = striker;
  this.isLazy     = true;
}

Entry.prototype.all = function() {
  if (this.isLazy) {
    var params = _.values(this.attributes);
    var values = this.collection.calculate.apply(this.collection, params);
    _.extend(this.attributes, values);
    this.isLazy = false;
  }
  return this.attributes;
};

Entry.prototype.get = function(key) {
  return this.all()[key];
};

// We can not get changed attributes exactly, but we can
// say which schema indticator for changed attributes
Entry.prototype.changedAttributes = function() {
  return _.pick(this.attributes, this.collection.schema);
};

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;
Entry.extend   = Backbone.Model.extend;

// expose to global namespace
window.Striker = Striker;
Striker.Entry  = Entry;
}).call(this, _, Backbone);
