module.exports =
  specialCondition: (value) ->
    if value
      if _(value).has('actual') then value.actual else value.plan
    else 0

  handle: (object, value) ->
    if object
      for key, val of value
        object[key] ||= 0
        object[key] += val

  merge: (value, part) ->
    if _.isArray(part)
      part
    else
      for key in _.keys(part)
        if _.isObject value[key]
          @merge value[key], part[key]
        else
          value[key] = part[key]
      value

  filter: (collection, conditions) ->
    _(collection).select (item) ->
      for key, value of conditions
        if _.isArray(value)
          return false unless _.include value, item[key]
        else
          return false unless value is item[key]
      return true

  mapped: (items, map, collectionFrom) ->
    for item in items
      id     = item[map.from]
      joinId = collectionFrom.get(id).get(map.to)
      item[map.to] = joinId
    items
