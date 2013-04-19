describe 'churn rates', ->
  beforeEach -> init
    collections: ['segments', 'periods']
    strikers: ['churn_rates']

  it "#get - returns value", ->
    expect(app.churnRates.get(7, 16)).equal(0.42)
    expect(app.churnRates.get(2, 18)).equal(0.18)
    expect(app.churnRates.get(2, 4)).equal(0)

  # describe 'set', ->
  #   appHelper.set 'when segmentId=7 monthId=1',
  #     collection: collection
  #     attributes: [0, 7, 1]
  #     results:
  #       conversionForecast:
  #         7: [10292,323,7,0,0,0,0,0,0,0,0,0,0,0,0,0,
  #             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  #       churnForecast:
  #         1: [5,7,0,2,1,0,0,0,2,2,3,3,3,1,1,0,
  #             1,1,1,1,5,2,4,6,0,1,2,1,0,2,2,4,0,3,1,0,0,3]
  #         4: [2,7,0,5,1,1,1,0,0,2,1,2,0,0,0,0,
  #             2,1,1,0,1,1,1,0,1,1,3,4,0,0,0,1,0,3,0,0,0,0]
  #         7: [323,7,0,4,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
  #             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  #       customerForecast:
  #         1: [5,7,2,1,0,0,0,7,6,7,4,3,1,2,1,2,2,
  #             1,3,8,3,6,8,2,3,3,1,1,4,5,4,0,3,1,0,0,7,4]
  #         4: [2,7,6,1,1,1,0,0,4,2,2,0,0,1,2,3,2,2,
  #             1,1,1,1,0,3,3,5,4,0,0,1,1,0,3,0,0,0,0,1]
  #         7: [323,7,5,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  #             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

  # appHelper.set 'when segmentId=2 monthId=4',
  #   collection: collection
  #   attributes: [100, 2, 4]
  #   results:
  #     conversionForecast:
  #       6: [10292,2,2,4,9,10,4,2,9,0,10,1,3,1,2,
  #           4,4,5,0,3,8,6,6,10,5,9,8,5,8,6,4,10,9,3,1,2,3,4,9]
  #     churnForecast:
  #       6: [2,2,13,3,4,1,3,0,0,5,1,1,2,0,1,0,1,1,
  #           4,0,0,2,1,0,5,1,1,1,2,3,2,2,3,6,1,1,0,0]
  #       15: [54244,2,3,1,2,2,0,0,0,1,1,0,2,0,1,0,3,
  #            2,3,0,1,6,1,0,0,1,0,1,1,2,1,0,1,0,0,1,1,3]
  #     customerForecast:
  #       6: [2,2,7,4,1,3,0,0,7,2,3,2,0,1,1,2,3,
  #           5,1,1,2,1,0,6,3,6,8,8,6,6,5,3,7,2,1,0,0,1]
  #       15: [54244,2,3,2,2,0,0,0,1,2,1,2,1,2,1,6,
  #            4,4,2,3,7,1,0,0,2,1,4,3,4,2,1,1,0,1,1,2,7,8]
