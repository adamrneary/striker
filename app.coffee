app = require('showcase').app(__dirname)
{isAuth, docco} = require('showcase')

app.configure 'development', ->
  require('brunch').watch({})

app.configure 'production', ->
  require('brunch').build({})
  app.set('github-client-id', '82102b21492744f5be7e')
  app.set('github-client-secret', '97dfcb37004236efd4d86508f25f072f25789257')

app.get '/', isAuth, (req, res) ->
  res.render 'examples/index'

app.get '/performance', isAuth, (req, res) ->
  res.render 'examples/performance'

app.get '/tests', isAuth, (req, res) ->
  res.render 'examples/iframe', url: '/test_runner.html'

app.get '/documentation', isAuth, (req, res) ->
  res.render 'examples/iframe', url: '/docs/striker.html'

app.start()

# Generate documenation
docco(files: '/src/striker.coffee', output: '/public/docs', root: __dirname, layout: 'linear')