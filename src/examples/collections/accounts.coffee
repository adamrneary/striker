module.exports = class Accounts extends Backbone.Collection
  revenue: ->
    @where(type: 'Revenue')