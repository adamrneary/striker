Collection = require('collections/shared/collection')
Customer   = require('models/customer')

module.exports = class Customers extends Collection
  url: 'api/v1/customers'
  model: Customer

  # Stub
  revenue: (periodId) ->

  comparator: (customer) ->
    -customer.trailing12mRevenue()
