{request, app, expect} = require('../test_helper')

describe 'Server', ->
  it '/', (done) ->
    request(app)
      .get('/')
      .expect(200)
      .end(done)

  it '/performance', (done) ->
    request(app)
      .get('/performance')
      .expect(200)
      .end(done)
