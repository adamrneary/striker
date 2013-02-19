# This class adds additional functionality to Backbone.Collection
# It's a base class for hash-like inputs like: channels, stages and etc.
#
# printAttributes - Describes order and attributes for print
# name            - Name of collection (required)
#
# Examples
#
#   class Stages extends BackboneCollection
#     name: 'stages'
#     printAttributes: ['id', 'name', 'is_topline']
#
#   stages = new Stages()
#   stages.models
#   # => [Backbone.Model, ..., Backbone.Model]
#
#   stages.print()
#   # => [[1, 'Stage 1', true], [2, 'Stage 2', false], ..., [n, 'Stage n', false]]
class BackboneCollection extends Backbone.Collection
  printAttributes: ['id', 'name']

  # Initializes data based on support/inputs.coffee
  initialize: ->
    @reset admin.inputs[@name]

  # Uses for display data in views.
  #
  # Returns array of nested arrays with values from printAttributes.
  print: ->
    for model in @models
      (model.get(attr) for attr in @printAttributes)
