Collection = require('collections/shared/collection')
Stage      = require('models/stage')

module.exports = class Stages extends Collection
  url: 'api/v1/stages'
  model: Stage

  comparator: (stage) ->
    -stage.get('position')

  topline: ->
    @max (stage) -> stage.get('position')

  customer: ->
    @min (stage) -> stage.get('position')

  notCustomerIds: ->
    @idsWithout [@customer().id]

  notToplineIds: ->
    @idsWithout [@topline().id]

  savePositions: ->
    Backbone.sync 'update', @,
      url: @url + '/update_positions'
