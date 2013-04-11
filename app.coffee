app = require('showcase').app(__dirname)
{isAuth, docco} = require('showcase')

app.configure 'development', ->
  require('brunch').watch({})

app.configure 'production', ->
  app.set('github-client-id', '82102b21492744f5be7e')
  app.set('github-client-secret', '97dfcb37004236efd4d86508f25f072f25789257')

app.get '/', isAuth, (req, res) ->
  res.render 'examples/index'

app.get '/performance', isAuth, (req, res) ->
  res.render 'examples/performance',
    examples: [
      { title: 'Channel Segment Mix', id: 'channelSegmentMix', count: 1000 }
      { title: 'Initial volume',      id: 'initialVolume',     count: 1000 }
      { title: 'Topline Growth',      id: 'toplineGrowth',     count: 1000 }
      { title: 'Conversion rates',    id: 'conversionRates',   count: 1000 }
      { title: 'Churn rates',         id: 'churnRates',        count: 1000 }
    ]

app.get '/tests', isAuth, (req, res) ->
  res.render 'examples/iframe', url: '/test_runner.html'

app.get '/documentation', isAuth, (req, res) ->
  res.render 'examples/iframe', url: '/docs/striker.html'

app.start()

# Generate documenation
docco(files: '/src/striker.coffee', output: '/public/docs', root: __dirname, layout: 'linear')