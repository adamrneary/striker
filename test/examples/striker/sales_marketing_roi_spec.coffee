Periods               = require('collections/periods')
Revenue               = require('striker/revenue')
SalesMarketingExpense = require('striker/sales_marketing_expense')
SalesMarketingRoi     = require('striker/sales_marketing_roi')

# describe 'sales & marketing roi', ->
#   beforeEach ->
#     app.periods = new Periods [
#       {id: 'last-month',    first_day: '2012-01-01'},
#       {id: 'this-month',    first_day: '2012-02-01'},
#       {id: 'next-month',    first_day: '2012-03-01'},
#       {id: 'two-years-ago', first_day: '2010-02-14'},
#     ]

#     app.revenue               = new Revenue()
#     app.salesMarketingExpense = new SalesMarketingExpense()

#     spyOn(Revenue::, 'get').andCallFake (periodId) ->
#       switch periodId
#         when 'last-month'    then actual: 100, plan: 500
#         when 'this-month'    then actual: 200, plan: 600
#         when 'next-month'    then actual: 300, plan: 700
#         when 'two-years-ago' then actual: 400, plan: 800

#     spyOn(SalesMarketingExpense::, 'get').andCallFake (periodId) ->
#       switch periodId
#         when 'last-month'    then actual: 50,  plan: 60
#         when 'this-month'    then actual: 70,  plan: 80
#         when 'next-month'    then actual: 90,  plan: 100
#         when 'two-years-ago' then actual: 110, plan: 120

#     @analysis = new SalesMarketingRoi()

#   # salesMarketingRoi = (revenue - salesMarketingExpense) / salesMarketingExpense
#   describe 'get', ->
#     it 'returns object with period ids', ->
#       result = @analysis.get ['last-month', 'this-month', 'next-month']
#       expect(_.keys result).toEqual ['last-month', 'this-month', 'next-month']

#     it 'result contains analysis data for periodId', ->
#       result = @analysis.get ['last-month', 'this-month', 'next-month']

#       expect(result['last-month'].actual).toBeCloseTo 1.00, 2
#       expect(result['last-month'].plan).toBeCloseTo   7.33, 2
#       expect(result['next-month'].actual).toBeCloseTo 2.33, 2
#       expect(result['next-month'].plan).toBeCloseTo   6.00, 2

#     it 'returns value by periodId', ->
#       result = @analysis.get 'this-month'

#       expect(result.actual).toBeCloseTo 1.86, 2
#       expect(result.plan).toBeCloseTo   6.50, 2
