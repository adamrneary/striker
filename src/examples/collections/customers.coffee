class Customer extends Backbone.Model

Striker.addAnalysis(Customer, 'revenue', analysis: 'customerRevenue')

module.exports = class Customers extends Backbone.Collection
  model: Customer
