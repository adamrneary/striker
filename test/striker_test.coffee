describe 'Striker', ->
  expect = chai.expect

  it 'constructor', ->
    expect(Striker).exist
    expect(Striker.Collection).exist

    streams = [
      {id: 2342, name: 'Revenue stream 1'}
      {id: 21231, name: 'Revenue stream 2'}
      {id: 123, name: 'Revenue stream 3'}
    ]
    expect(new Striker.Collection(streams)).ok
