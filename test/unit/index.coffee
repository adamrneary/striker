describe 'unit tests', ->
  before (done)->
    glob.zombie.visit glob.url, (e, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      _ = window._

      global.browser = browser
      global.window = window
      global.d3 = browser.window.d3
      global._ = window._
      global.Backbone = browser.window.Backbone
      #if glob.report
      require("#{__dirname}/../cov/#{glob.config.name}.js")
      done()

  require './collection_test'
  #require './channel_segment_mix_test'
