module.exports = class Stage extends Backbone.Model
  lag: ->
    @get('lag_periods') ? 0