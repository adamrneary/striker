;(function(_, Backbone) {
'use strict';

// expose to global namespace
window.Striker = Striker;

/**
 * Define `Striker` constructor
 */

function Striker(inputs) {
  if (!inputs) inputs = [];
  var collections = _.map(this.schema, Striker.schemaMap);
  this.values = initValues(collections, inputs, {}, 0);
  build(collections, this, [], 0);
}

_.extend(Striker.prototype, Backbone.Events, {
  // Default multiplier is 1, to avoid altering data unless requested
  multiplier: 1,

  // Array with collection IDs which map with Striker.schemaMap
  schema: [],

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
  }
});

/**
 * Static methods
 */

// Setup schema mapping, to transform keys to real models
Striker.schemaMap = function() {
  throw new Error('CRITICAL: Override this');
};

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;

/**
 * Helpers
 */

// Generate values based on schema
function initValues(collections, inputs, values, level) {
  if (!collections[level]) return values;
  for (var i = 0, len = collections[level].length, item, value; i < len; i++) {
    value = inputs[i] || {};
    item  = collections[level][i];
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

}).call(this, _, Backbone);
