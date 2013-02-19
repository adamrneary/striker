name = 'striker'

port = process.env.PORT or 5000

modules =
  http: require 'http'
  fs: require 'fs'
  express: express = require 'express'
  path: require 'path'
  kss: require 'kss'
  jade: require 'jade'
  coffeelint: require 'coffeelint'
  #async: require 'async'

app = express()

app.configure ->
  app.set('port', port)
  app.set('views', __dirname + '/../examples/views')
  app.set('view engine', 'jade')
  app.use express.favicon()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static "#{__dirname}/../examples/public/"
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

compiler = require('./compiler')
compiler.name = name
compiler.css = 'scss'
compile = require('./compiler').compile

app.get '/', (req,res)->
  compile ->
    res.render 'index'
      page: 'index'

app.get '/performance', (req,res)->
  compile ->
    res.render 'performance'
      page: 'performance'

app.get '/documentation', (req,res)->
  compile ->
    docs = {}
    docsPath = "#{__dirname}/../test/docs/"
    docFiles = modules.fs.readdirSync docsPath
    for docFile in docFiles
      if docFile.substr(docFile.length-4) == 'html'
        htmlBody = modules.fs.readFileSync docsPath + docFile, 'utf-8'
        jsReg = /<body>([\s\S]*?)<\/body>/gi
        container = jsReg.exec(htmlBody)
        docs[docFile] = container[1]

    res.render 'documentation'
      docs: docs
      page: 'documentation'

app.get '/test', (req,res)->
  compile ->
    errors = {}
    pathes = {}

    path = "#{__dirname}/../src/coffee/"
    files = modules.fs.readdirSync path
    for f in files
      contents = modules.fs.readFileSync path + f, 'utf-8'
      errors[f] = modules.coffeelint.lint contents

    path2="#{__dirname}/../examples/public/coffee/"
    files2 = modules.fs.readdirSync path2
    for t in files2
      contents = modules.fs.readFileSync path2 + t, 'utf-8'
      errors[t] = modules.coffeelint.lint contents

    path3="#{__dirname}/../server/"
    files3 = modules.fs.readdirSync path3
    for d in files3
      contents = modules.fs.readFileSync path3 + d, 'utf-8'
      errors[d] = modules.coffeelint.lint contents

    res.render 'mocha'
      errors: errors
      page: 'mocha'

app.get "/js/#{name}.js", (req,res)->
  script = modules.fs.readFileSync "#{__dirname}/../dist/#{name}.js"
  res.setHeader 'Content-Type', 'text/javascript'
  res.setHeader 'Content-Length', script.length
  res.end script

app.get "/css/#{name}.css", (req,res)->
  style = modules.fs.readFileSync "#{__dirname}/../dist/#{name}.css"
  res.setHeader 'Content-Type', 'text/css'
  res.setHeader 'Content-Length', style.length
  res.end style

modules.http.createServer(app).listen port, ->
  console.log  'server start on port '+port
