window.appHelper =
  set: (description, options) ->
    {collection, attributes, results} = options

    oldAtributes = _.clone(attributes)
    oldAtributes[0] = collection.get(attributes.slice(1)...) * collection.multiplier

    describe description, ->
      for forecastName, testResults of results
        describe "changes #{forecastName}", ->
          # beforeEach
          collection.set(attributes...)
          result = app[forecastName].print()

          for row, values of testResults
            spec = it "returns array for row=#{row}", ->
              expect(result[parseInt(@row) - 1]).toEqual @values

            spec.row    = row
            spec.values = values
          # afterEach
          collection.set(oldAtributes...)

  getAndPrint: (options) ->
    {collection, getParams, printParams} = options

    describe 'get', ->
      for value, keys of getParams
        output = ''
        output += " #{collection.schema[order]}=#{key}" for key, order in keys

        spec = it "returns #{value} for #{output}", ->
          expect(collection.get(@keys...)).toEqual parseFloat(@value)

        spec.keys  = keys
        spec.value = value

    describe 'print', ->
      result = collection.print()
      for row, values of printParams
        spec = it "returns array for row=#{row}", ->
          expect(result[@row - 1]).toEqual @values

        spec.row    = row
        spec.values = values
