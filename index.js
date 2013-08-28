;(function(_, Backbone) {
'use strict';

/**
 * Define `Striker` constructor
 */

function Striker(options) {
  if (!options) options = {};

  this.values  = {};
  this.entries = [];
  this.Entry   = Entry.extend({});
  this._initCollections();
  this._initEntries(this.collections, this.values, {}, 0);

  defineCustomAttributes(this);
  options.careful ?
    Striker.once('enable-observers', this._enableObservers, this) :
    this._enableObservers();
}

// Convenient method to get one value based on schema
Striker.prototype.get = function() {
  try {
    var args   = _.toArray(arguments);
    var result = this.values;

    for (var i = 0, len = args.length; i < len; i++) result = result[args[i]];
    return result;
  } catch (err) {
    console.log('FIX IT:', err.message, _.toArray(arguments), this);
  }
};

// Convenient method to trigger `change` event and force lazy calculations
Striker.prototype.update = function() {
  var entry = this.get.apply(this, arguments);
  if (!entry.isLazy) {
    this.trigger('change', entry, _.toArray(arguments));
    entry.isLazy = true;
  }
};

// Enable collections observers for `add`&`remove` events
Striker.prototype._initCollections = function() {
  var that = this;
  this.collections = _.map(this.schema, Striker.schemaMap);
  _.forEach(this.schema, function(key, index) {
    var coll = _.first(that.collections[index]).collection;

    coll.on('remove', function(model) {
      var attrs    = _.object([[key, model.id]]);
      var entries  = that.where(attrs);
      that.entries = _.difference(that.entries, entries);
      _.forEach(entries, function(entry) { that.trigger('remove', entry) });
    });

    coll.on('add', function(model) {
      var collections = _.without(that.collections, that.collections[index]);
      var item        = _.object([[key, model.id]]);
      that._initEntries(collections, item, 0, true);
    });
  });
};

// Initialize entries based on schema
Striker.prototype._initEntries = function(collections, values, item, level, trigger) {
  var key    = this.schema[level];
  var models = collections[level];

  for (var i = 0, len = models.length, modelId; i < len; i++) {
    modelId   = models[i].id;
    item[key] = modelId;
    if (collections.length === level + 1) {
      var entry = new this.Entry(item, this);
      this.entries.push(entry);
      values[modelId] = entry;
      if (trigger) this.trigger('add', entry);
    } else {
      values[modelId] = {};
      this._initEntries(collections, values[modelId], item, level + 1);
    }
  }
};

// Setup collection observers based on `this.observers`
// Name `this` uses for self reference
Striker.prototype._enableObservers = function() {
  if (_.isEmpty(this.observers)) return;

  _.forEach(this.observers, function(callback, name) {
    var collection = name === 'this' ? this : Striker.namespace[name];
    collection.on('change', function(model, attrs) {
      if (model instanceof Backbone.Model)
        callback.call(this, model, model.changedAttributes());
      else
        callback.call(this, model, attrs);
      this.trigger('updateCompleted', this, arguments);
    }, this);
  }, this);
};

// Apply EventEmitter pattern and set default values
_.extend(Striker.prototype, Backbone.Events, {
  // Default multiplier is 1, to avoid altering data unless requested
  multiplier: 1,

  // Array with collection IDs which map with Striker.schemaMap
  schema: [],

  // Observers and event handling
  observers: {},

  // Raw method to calculate value, it calls on every `update`
  // Override it with striker's specific calculations
  calculate: function() { return {} },
});

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

// An ES5 magic:
// in order to define nice API and avoid constant `get`,
// we define CustomEntry for every striker, which contains necessary getters
// based on first not lazy calculation
function defineCustomAttributes(striker) {
  var entry   = _.first(striker.entries);
  var getters = _.uniq(_.keys(entry.all()));

  _.forEach(getters, function(name) {
    Object.defineProperty(striker.Entry.prototype, name, {
      // getter proxies to Entry#get()
      get: function() { return this.get(name) },
      // make it configurable and enumerable so it's easy to override...
      configurable: true,
      enumerable: true
    });
  });
}

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;
Entry.extend   = Backbone.Model.extend;
Striker.Entry  = Entry;

// expose to global namespace
window.Striker = Striker;

}).call(this, _, Backbone);
