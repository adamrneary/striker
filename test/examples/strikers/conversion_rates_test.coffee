describe 'Conversion rates', ->
  beforeEach -> init
    collections: ['stages', 'channels', 'periods']
    strikers: ['conversion_rates']

  it "#get - returns value", ->
    expect(app.conversionRates.get(22394, 323, 11)).equal(0.63)
    expect(app.conversionRates.get(32943, 4121, 36)).equal(0.93)

# describe 'set', ->
#   appHelper.set 'when notFirstStageId=22394 and channelId=5 and monthId=1',
#     collection: collection
#     attributes: [95, 22394, 5, 1]
#     results:
#       conversionForecast:
#         16: [22394,5,7,4,3,2,1,1,12,3,3,1,5,11,3,
#              0,1,2,12,12,11,0,9,7,3,5,2,5,1,14,11,6,1,3,2,0,0,12,0]
#         17: [22394,5,6,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
#              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
#         18: [22394,5,2,14,0,0,0,0,0,0,0,0,0,0,0,0,0,
#              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
#       churnForecast:
#         2: [5,6,1,2,2,0,1,0,0,0,0,0,0,0,0,0,0,
#             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
#       customerForecast:
#         2: [5,6,5,3,1,1,0,0,0,0,0,0,0,0,0,0,0,0,
#             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

#   appHelper.set 'when notFirstStageId=32943 and channelId=2 and monthId=2',
#     collection: collection
#     attributes: [98, 32943, 2, 2]
#     results:
#       conversionForecast:
#         36: [32943,2,2,1,1,1,3,0,0,7,0,2,0,0,1,1,
#              1,2,3,0,0,1,1,0,6,2,4,3,1,0,3,1,0,7,1,0,0,0,1]
#       churnForecast:
#         6: [2,2,13,3,5,0,3,1,0,5,1,1,2,0,1,0,1,
#             1,4,0,0,2,1,0,5,1,1,1,2,3,2,2,3,6,1,1,0,0]
#       customerForecast:
#         5: [2,6,4,2,2,2,1,0,4,1,2,1,0,1,1,2,2,2,
#             0,0,1,2,1,4,1,3,3,3,2,2,0,0,3,0,0,0,0,1]
