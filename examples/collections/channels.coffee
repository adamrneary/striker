Collection = require('lib/collection')
Channel    = require('models/channel')

module.exports = class Channels extends Collection
  url: 'api/v1/channels'
  model: Channel

  # Stub
  salesMarketingExpense: ->
  newCustomers: ->
  defaultId: ->
    app.channels.first().get('id')

