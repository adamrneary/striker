class Channel extends Backbone.Model

Striker.addAnalysis(Channel, 'reach')

module.exports = class Channels extends Backbone.Collection
  model: Channel
  # Just stub
  toplineId: -> 'topline'
