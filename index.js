/* globals _,Backbone,Indexed */
;(function(_, Backbone) {
'use strict';

/**
 * Base `Striker` object
 */

function Striker() {
  this.values = {};
}

_.extend(Striker.prototype, Backbone.Events, {
  // Default multiplier is 1, to avoid altering data unless requested
  multiplier: 1,

  // Array with collection IDs which map with Striker.setSchemaMap
  schema: override,

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
  // @returns nothing.
  update: function() {
    var value = this.calculate.apply(this, arguments);
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
Striker.setSchemaMap = override;

function override() {
  throw new Error('CRITICAL: Override this in each subclass');
}

// export to window namespace
window.Striker = Striker;
}).call(this, _, Backbone, Indexed);
