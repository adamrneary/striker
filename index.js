;(function(_, Backbone) {
'use strict';

// expose to global namespace
window.Striker = Striker;

/**
 * Define `Striker` constructor
 */

function Striker() {
  this.collections = _.map(this.schema, Striker.schemaMap);
  this.entries     = [];
  this._initEntries({}, 0);
  this._enableObservers();
}

// Convinient methods to get one value based on schema
Striker.prototype.get = function() {
  var args   = _.toArray(arguments);
  var params = _.object(_.map(this.schema, function(schemaId, index) {
    return [schemaId, args[index]];
  }));
  return this.where(params, true);
};

Striker.prototype.update = function() {
  var entry = this.get.apply(this, arguments);
  if (!entry.isLazy) this.trigger('change', this, _.toArray(arguments), entry);
  entry.isLazy = true;
};

// Initialize entries based on schema
Striker.prototype._initEntries = function(item, level) {
  var key    = this.schema[level];
  var models = this.collections[level];

  for (var i = 0, len = models.length; i < len; i++) {
    item[key] = models[i].id;
    if (this.schema.length === level + 1) this.entries.push(new Entry(item, this));
    else this._initEntries(item, level + 1);
  }
};

// Setup collection observers based on `this.observers`
// Name `this` uses for self reference
Striker.prototype._enableObservers = function() {
  if (_.isEmpty(this.observers)) return;

  _.forEach(this.observers, function(callback, name) {
    var collection = name === 'this' ? this : Striker.namespace[name];
    collection.on('change', callback, this);
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

// Apply more relevant underscore's methods
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

// expose `Entry`
Striker.Entry = Entry;

// Setup schema mapping, to transform keys to real models
Striker.schemaMap = function() {
  throw new Error('CRITICAL: Override this');
};

// Define default namespace for observers
Striker.namespace = window;

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;

/**
 * Define `Entry`
 * It uses to perform lazy evaluations
 */

function Entry(attrs, striker) {
  this.attributes = _.clone(attrs);
  this.striker    = striker;
  this.isLazy     = true;
}

Entry.prototype.all = function() {
  if (this.isLazy) {
    var params = _.values(this.attributes);
    var values = this.striker.calculate.apply(this.striker, params);
    _.extend(this.attributes, values);
    this.isLazy = false;
  }
  return this.attributes;
};

Entry.prototype.get = function(key) {
  return this.all()[key];
};

}).call(this, _, Backbone);
