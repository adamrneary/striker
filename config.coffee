{path, defaultConfig} = require('showcase')

# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config = defaultConfig
  files:
    javascripts:
      joinTo:
        'assets/striker.js'    : path('src/striker.coffee')
        'assets/examples.js'   : path('src/examples/collections/*', 'src/examples/striker/*')
        'assets/unit_tests.js' : path('test/striker_test.coffee', 'test/examples/striker/*', 'test/examples/test_helper.coffee')
