examples = [
  { title: 'Channel Segment Mix', id: 'channelSegmentMix', count: 1000 }
  { title: 'Initial volume', id: 'initialVolume', count: 1000 }
  { title: 'Topline Growth', id: 'toplineGrowth', count: 1000 }
  { title: 'Conversion rates', id: 'conversionRates', count: 1000 }
  { title: 'Churn rates', id: 'churnRates', count: 1000 }
]

exports.index = (req, res) ->
  res.render 'examples/index',
    page: 'index'

exports.performance = (req, res) ->
  res.render 'examples/performance',
    page: 'performance'
    examples: examples
