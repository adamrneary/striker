class Row extends Backbone.View
  tagName: 'tr'

  render: ->
    for field in @collection
      @$el.append $("<td>#{field}</td>")
    @
