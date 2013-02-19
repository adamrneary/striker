describe 'ConversionForecast', ->
  collection = admin.conversionForecast

  AdminHelper.getAndPrint
    collection: collection
    getParams:
      4: [10292, 5, 7, 1] # topline=true customer=true
      0: [10292, 5, 6, 35]
      5: [10292, 54244, 7, 11]
      11: [22394, 2, 2, 1] # topline=false and customer=false
      2: [22394, 54244, 2, 1]
      7: [22394, 2, 2, 7]
      1: [22394, 4121, 7, 35]
      3: [32943, 54244, 6, 1] # topline=false and customer=true
      10: [32943, 323, 6, 11]
    printParams:
      1: [10292,5,7,4,4,4,17,17,7,7,4,12,18,4,1,15,3,18,18,16,8,14,20,4,17,11,18,17,20,13,12,1,12,16,0,3,13,2,0]
      25: [22394,4121,7,5,1,0,1,0,1,0,0,1,0,3,0,1,1,1,1,0,0,0,0,0,2,1,0,1,1,1,3,0,0,1,0,1,0,1,0]