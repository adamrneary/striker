describe "Striker", ->

  it 'constructor', (done) ->
    Striker = window.Striker
    assert Striker
    assert Striker.Collection
    streams = [
      {id: 2342, name: 'Revenue stream 1'}
      {id: 21231, name: 'Revenue stream 2'}
      {id: 123, name: 'Revenue stream 3'}
    ]

    assert new Striker.Collection streams
    done()
