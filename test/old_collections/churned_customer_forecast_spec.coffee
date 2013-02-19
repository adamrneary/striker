describe 'ChurnForecast', ->
  collection = app.churnForecast

  appHelper.getAndPrint
    collection: collection
    getParams:
      2: [5, 7, 1]
      1: [54244, 6, 1]
      3: [2, 2, 2]
    printParams:
      2: [5,6,1,2,2,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      15: [54244,2,3,1,2,0,2,0,0,1,1,0,2,0,1,0,3,2,3,0,1,6,1,0,0,1,0,1,1,2,1,0,1,0,0,1,1,3]