window.expect = chai.expect
App.initialize()

window.appHelper =
  set: (description, options) ->
    {collection, attributes, results} = options

    oldAtributes = _.clone(attributes)
    attr = collection.get(attributes.slice(1)...)
    oldAtributes[0] = attr * collection.multiplier

    describe description, ->
      for forecastName, testResults of results
        describe "changes #{forecastName}", ->
          # beforeEach
          collection.set(attributes...)
          result = app[forecastName].print()

          for row, values of testResults
            spec = it "returns array for row=#{row}", ->
              expect(result[parseInt(@row) - 1]).equal @values

            spec.row    = row
            spec.values = values
          # afterEach
          collection.set(oldAtributes...)

  getAndPrint: (options) ->
    {collection, getParams, printParams} = options

    describe 'get', ->
      _.each getParams, (keys, value) ->
        output = ''
        output += " #{collection.schema[order]}=#{key}" for key, order in keys

        it "returns #{value} for #{output}", ->
          expect(collection.get(keys...)).equal parseFloat(value)

    describe 'print', ->
      result = collection.print()
      _.each printParams, (values, row) ->
        it "returns array for row=#{row}", ->
          expect(result[row - 1]).eql values
