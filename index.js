/* globals _,Backbone,Indexed */
;(function(_, Backbone, Indexed) {
'use strict';

/**
 * Constructor for all Strikers
 */

function Striker() {
  this.values = {};
}

// Extend constructor with Backbone.Events
_.extend(Striker.prototype, Backbone.Events);

// Default multiplier is 1, to avoid altering data unless requested
Striker.prototype.multiplier = 1;

/**
 * Get value by arguments
 *
 * Examples:
 *
 *   // Reach has schema = ['channel_id', 'period_id']
 *   reach.get(2, 1)
 *   // => channel_id=2, period_id=1, returns value, like 70
 *   reach.get(2)
 *   // => channel_id=2, returns object, like {1: 70, 2: 17, ..., 36: 27}
 *
 * @param {Anything} args - arguments based on schema
 * @returns {Object|Anything} - end value or partial object
 */

Striker.prototype.get = function() {
  var args   = _.toArray(arguments);
  var result = this.values;

  for (var i = 0, len = args.length; i < len; i++) result = result[args[i]];
  if (this.multiplier !== 1 && _.isNumber(result)) result = result / this.multiplier;

  return result;
};

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;

/**
 * Expose `Striker` to global namespace.
 */

window.Striker = Striker;

}).call(this, _, Backbone, Indexed);
