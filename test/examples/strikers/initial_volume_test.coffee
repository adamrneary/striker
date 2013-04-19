describe 'InitialVolume', ->
  beforeEach ->
    window.init
      collections: ['segments', 'channels', 'stages']
      strikers: ['initial_volume']

  it "#get - returns value", ->
    expect(app.initialVolume.get(10292, 2, 6)).equal(12)
    expect(app.initialVolume.get(22394, 54244, 2)).equal(15)

# describe 'set', ->
#   appHelper.set 'for stage_id=22394 channelId=323 and segmentId=2',
#     collection: collection
#     attributes: [700,22394,323,6]
#     results:
#       conversionForecast:
#         23: [22394,323,6,3,5,1,6,11,0,1,7,7,10,11,10,
#              0,9,1,12,0,4,0,8,2,8,3,0,13,2,6,8,4,3,0,1,9,1,7,3]
#       churnForecast:
#         8: [323,6,1,4,3,1,3,2,1,0,2,4,5,8,10,
#             0,1,2,9,2,1,0,4,2,9,2,0,1,1,3,13,0,2,2,0,1,2,2]
#       customerForecast:
#         8: [323,6,9,6,4,4,3,1,0,5,9,6,11,11,1,4,4,
#             11,2,1,0,6,4,10,2,0,6,6,9,13,1,4,2,0,2,2,5,5]

#   appHelper.set 'for stage_id=32943 channelId=5 and segmentId=6',
#     collection: collection
#     attributes: [300,32943,2,6]
#     results:
#       conversionForecast:
#         20: [22394,2,6,8,0,2,1,0,0,4,0,3,0,0,
#              1,1,2,1,2,0,1,1,2,0,3,2,3,4,0,0,2,1,0,4,2,0,1,0,1]
#         35: [32943,2,6,1,0,1,1,0,0,4,0,1,0,0,1,
#              1,1,1,1,0,0,1,1,0,3,1,3,2,0,0,1,0,0,3,0,0,0,0,1]
#       churnForecast:
#         5: [2,6,30,133,69,25,33,7,6,3,0,1,1,0,1,
#             0,1,1,2,0,0,0,1,0,4,1,2,0,1,1,2,0,0,3,0,0,0,0]
#       customerForecast:
#         5: [2,6,271,138,70,46,13,6,4,1,2,1,0,1,1,
#             2,2,2,0,0,1,2,1,4,1,3,3,3,2,2,0,0,3,0,0,0,0,1]
