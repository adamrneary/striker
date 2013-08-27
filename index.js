;(function(_, Backbone) {
'use strict';

// expose to global namespace
window.Striker = Striker;

/**
 * Define `Striker` constructor
 */

function Striker(options) {
  if (!options) options = {};

  this.collections = _.map(this.schema, Striker.schemaMap);
  this.lazy        = options.lazy || true;
  this.entries     = [];
  this._initEntries({}, 0);
}

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

Striker.prototype.get = function() {
  // body...
};

// Initialize entries based on schema
Striker.prototype._initEntries = function(item, level) {
  var key    = this.schema[level];
  var models = this.collections[level];

  for (var i = 0, len = models.length; i < len; i++) {
    item[key] = models[i].id;
    if (this.schema.length === level + 1) this.entries.push(_.clone(item));
    else this._initEntries(item, level + 1);
  }
};

/**
 * Static methods
 */

Striker.addAnalysis = function() {};

// Setup schema mapping, to transform keys to real models
Striker.schemaMap = function() {
  throw new Error('CRITICAL: Override this');
};

// Define default namespace for observers
Striker.namespace = window;

// Copy extend method for inheritance
Striker.extend = Backbone.Model.extend;

}).call(this, _, Backbone);
