class Customer extends Backbone.Model

Striker.addAnalysis(Customer, 'revenue')

module.exports = class Customers extends Backbone.Collection
  model: Customer
