# provides a number of additional convenience methods for collections
module.exports = class Collection extends Backbone.Collection
  # extracts ids
  ids: ->
    @pluck('id')

  eachIds: (callback) ->
    @map((item) => callback(item.id))

  # pulls the previous id in the collection if available
  # note: relies on collection comparator
  prevId: (id) =>
    index = _.indexOf @ids(), id
    if index is 0 then undefined else @at(index - 1)?.id

  # pulls the next id in the collection if available
  # note: relies on collection comparator
  nextId: (id) =>
    index = _.indexOf @ids(), id
    if index is @length then undefined else @at(index + 1)?.id

  # filters out ids in passed array
  idsWithout: (idsArray) ->
    idsArray = if _.isArray(idsArray) then idsArray else [idsArray]
    @chain()
      .select((item) -> not _.include idsArray, item.id)
      .pluck('id')
      .value()

  # applies a filter method to all models in a collection,
  # returning ids that meet the filter criteria
  # TODO: handle arguments--with help from someone that knows js??? :-
  filterIds: (method, args...) ->
    @chain()
      .select((model) -> model[method]())
      .pluck('id')
      .value()

  wrappedWhere: (comparison) ->
    if _.isFunction(comparison)
      new @constructor(
        @filter((model) -> comparison(model))
      )
    else
      new @constructor(
        @where(comparison)
      )

  nameIsUsed: (name) =>
    @where(name: name).length > 0

  nextNewName: =>
    newName = "New "+
      @model.name.replace(/([a-z])([A-Z])/g, '$1 $2').toLowerCase()
    if @nameIsUsed(newName)
      i = 1
      rawName = newName
      while @nameIsUsed(newName)
        newName = rawName + ' ' + i
        i += 1
    newName
