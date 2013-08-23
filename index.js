/* globals _,Backbone,Indexed */
;(function(_, Backbone) {
'use strict';

/**
 * Base `Striker` object
 */

function Striker(inputs) {
  if (!inputs) inputs = [];
  this.values = initValues(getCollections(this), {}, inputs, 0);
}

_.extend(Striker.prototype, Backbone.Events, {
  // Default multiplier is 1, to avoid altering data unless requested
  multiplier: 1,

  // Array with collection IDs which map with Striker.setSchemaMap
  schema: [],

  // Raw method to calculate value
  calculate: override,

  // Get value by arguments
  //
  // @param {Anything} args... - arguments based on schema
  // @returns {Object|Anything} - end value or partial object
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

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;

// Setup schema mapping
Striker.schemaMap = override;

// Calculate sum for collection of Backbone.Model
Striker.sum = function(collection, field) {
  return collection.reduce(function(memo, item){
    return memo + item.get(field);
  }, 0);
};

/**
 * Helpers
 */

function override() {
  throw new Error('CRITICAL: Override this');
}

function initValues(collections, values, inputs, level) {
  if (!collections[level]) return values;
  for (var i = 0, len = collections[level].length, item, value; i < len; i++) {
    value = inputs[i] || {};
    item  = collections[level][i];
    values[item.id] = value;
    initValues(collections, values[item.id], value, level + 1);
  }
  return values;
}

function getCollections(striker) {
  return _.map(striker.schema, Striker.schemaMap);
}

// export to window namespace
window.Striker = Striker;

}).call(this, _, Backbone, Indexed);
