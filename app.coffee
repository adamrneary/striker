app   = require('./lib')(__dirname)
grunt = require('grunt')

examples = [
  { title: 'Channel Segment Mix', id: 'channelSegmentMix', count: 1000 }
  { title: 'Initial volume',      id: 'initialVolume',     count: 1000 }
  { title: 'Topline Growth',      id: 'toplineGrowth',     count: 1000 }
  { title: 'Conversion rates',    id: 'conversionRates',   count: 1000 }
  { title: 'Churn rates',         id: 'churnRates',        count: 1000 }
]

index = (req, res) ->
  res.render 'examples/index'

performance = (req, res) ->
  res.render 'examples/performance',
    examples: examples

app.setup ->
  app.get('/', index)
  app.get('/performance', performance)
  grunt.tasks('')
