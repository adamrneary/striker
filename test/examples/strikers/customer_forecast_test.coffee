describe 'customer forecast', ->
  beforeEach -> init
    collections: ['segments', 'periods']
    strikers: ['customer_forecast']

  it "#get - returns value", ->
    expect(app.customerForecast.get(5, 7, 1)).equal(0)
    expect(app.customerForecast.get(54244, 6, 1)).equal(16)
    expect(app.customerForecast.get(2, 7, 3)).equal(1)
