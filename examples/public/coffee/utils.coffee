window.l = (values...) ->
  console.log(values...)

window.timeLog = (description, callback) ->
  start = (new Date).getTime()
  callback()
  diff = (new Date).getTime() - start
  l("#{description} \t: #{diff}ms or #{(diff/1000).toFixed 2}s") unless isTest()

window.isTest = ->
  /(\d{1,3}\.){3}/.test(location.host)

_.mixin
  sum: (object) ->
    _.reduce object, ((memo, val) -> memo += val), 0

  toCamel: (string) ->
    string.replace /(\-[a-z]|^[a-z])/g, ($1) ->
      $1.toUpperCase().replace('-','')
