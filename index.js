;(function(_, Backbone) {
'use strict';

// expose to global namespace
window.Striker = Striker;

/**
 * Define `Striker` constructor
 */

function Striker(inputs) {
  if (!inputs) inputs = [];
  this.collections = _.map(this.schema, Striker.schemaMap);
  this.values = initValues(this.collections, inputs, {}, 0);
  this.enableObservers();
  build(this.collections, this, [], 0);
}

_.extend(Striker.prototype, Backbone.Events, {
  // Default multiplier is 1, to avoid altering data unless requested
  multiplier: 1,

  // Array with collection IDs which map with Striker.schemaMap
  schema: [],

  // Observers and event handling
  observers: {},

  // Raw method to calculate value, it calls on every `update`
  // Override it with striker's specific calculations
  calculate: function() { return 0 },

  // Get value by arguments
  //
  // @param {Anything} args... - arguments based on schema
  // @returns {Object} - value or partial object
  get: function() {
    var args   = _.toArray(arguments);
    var result = this.values;

    for (var i = 0, len = args.length; i < len; i++) result = result[args[i]];
    if (this.multiplier !== 1 && _.isNumber(result)) result = result / this.multiplier;

    return result;
  },

  // Recalculate value and trigger `change` event.
  //
  // @param {Anything} value
  // @param {Anything} args... - navigate to specific value
  update: function() {
    var value     = this.calculate.apply(this, arguments);
    var prevValue = this.get.apply(this, arguments);
    if (value === prevValue) return;

    var partValue = this.get.apply(this, _.initial(arguments));
    partValue[_.last(arguments)] = value;
    this.trigger('change', this, _.toArray(arguments), value);
  },

  // transform `this.values` to array
  flat: function() {
    return flat(this.collections, this, [], [], 0);
  },

  // return values in reversed schema order
  reverse: function() {
    return reverse(this.schema, _.toArray(this.values), {}, 0);
  },

  enableObservers: function() {
    if (_.isEmpty(this.observers)) return;
    for (var name in this.observers) {
      var callback   = this.observers[name];
      var collection = name === 'this' ? this : Striker.namespace[name];
      collection.on('change', wrapCallback(callback), this);
    }
  }
});

/**
 * Static methods
 */

Striker.addAnalysis = function(Model, methodName, options) {
  if (!options) options = {};
  Model.prototype[methodName] = function() {
    var striker = Striker.namespace[options.analysis || methodName];
    var args    = _.toArray(arguments);
    return args.length > 0 ?
      striker.get.apply(striker, [this.id].concat(args)) :
      flat(striker.collections, striker, [], [this.id], 1);
  };
};

// Setup schema mapping, to transform keys to real models
Striker.schemaMap = function() {
  throw new Error('CRITICAL: Override this');
};

// Define default namespace for observers
Striker.namespace = window;

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;

/**
 * Helpers
 */

// Generate values based on schema
function initValues(collections, inputs, values, level) {
  if (!collections[level]) return values;
  for (var i = 0, len = collections[level].length, item, value; i < len; i++) {
    item  = collections[level][i];
    value = inputs[i] || {};
    values[item.id] = value;
    initValues(collections, value, values[item.id], level + 1);
  }
  return values;
}

// Update values
function build(collections, striker, args, level) {
  for (var i = 0, len = collections[level].length, item; i < len; i++) {
    item = collections[level][i];
    args[level] = item.id;
    if (level >= collections.length - 1)
      striker.update.apply(striker, args);
    else
      build(collections, striker, args, level + 1);
  }
}

function flat(collections, striker, result, args, level) {
  for (var i = 0, len = collections[level].length, item, object; i < len; i++) {
    item = collections[level][i];
    args[level] = item.id;
    if (level === collections.length - 1) {
      object = {};
      for (var j = 0, len2 = args.length; j < len2; j++) object[striker.schema[j]] = args[j];
      result.push(_.extend(object, striker.get.apply(striker, args)));
    } else {
      flat(collections, striker, result, args, level + 1);
    }
  }
  return result;
}

function reverse(schema, values, result, level) {
  for (var i = 0, len = values.length, item; i < len; i++) {
    item = values[i];
    if (level === schema.length - 1) {
      var key  = schema[level];
      var pKey = schema[level - 1];
      if (_.isUndefined(result[item[key]])) result[item[key]] = {};
      result[item[key]][item[pKey]] = item;
    } else {
      reverse(schema, _.toArray(item), result, level + 1);
    }
  }
  return result;
}

function wrapCallback(cb) {
  return function(model, args, value) {
    if (model instanceof Backbone.Model)
      cb.call(this, model, model.changed);
    else
      cb.call(this, model, args, value);
    this.trigger('updated', this, args);
  };
}

}).call(this, _, Backbone);
