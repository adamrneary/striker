toUnderscore = (string) ->
  string.replace /([A-Z])/g, ($1) ->
    "_" + $1.toLowerCase()

module.exports = class BaseModel extends Backbone.Model
  @hasAnalyse: (analysisName, options = {}) ->
    analysis        = require("striker/#{options.file ? toUnderscore(analysisName)}")
    options.name    = @['name'].toLowerCase()
    options.groupBy = [options.name + '_id']
    extend = analysis['extend'](analysisName, options)
    _.extend @::, extend
