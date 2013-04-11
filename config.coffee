{path, defaultConfig} = require('showcase')

# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config = defaultConfig
  files:
    javascripts:
      joinTo:
        'assets/striker.js'  : path('src/striker.coffee')
        'assets/examples.js' : path('')

# 'public/assets/examples.js': ['examples/lib/*.coffee', 'examples/collections/*.coffee', 'examples/models/*.coffee', 'examples/striker/*.coffee']
# 'public/tests/striker_test.js'         : 'test/striker_test.coffee'
# 'public/tests/examples/test_helper.js' : 'test/examples/test_helper.coffee'
# 'public/tests/examples/striker.js'     : ['test/examples/striker/*.coffee']