describe 'CustomerForecast', ->
  collection = app.customerForecast

  appHelper.getAndPrint
    collection: collection
    getParams:
      0: [5, 7, 1]
      16: [54244, 6, 1]
      1: [2, 7, 3]
    printParams:
      1: [5,7,0,1,0,0,0,7,6,7,4,3,1,2,1,2,2,1,3,8,3,6,8,2,3,3,1,1,4,5,4,0,3,1,0,0,7,4]
      12: [4121,2,5,3,1,1,0,1,2,1,2,1,2,2,2,1,0,0,0,0,1,0,0,3,3,2,3,2,3,2,1,1,2,0,3,1,2,1]