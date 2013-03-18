module.exports = (grunt) ->
  examples = ['examples/lib/*.coffee', 'examples/collections/*.coffee', 'examples/models/*.coffee', 'examples/striker/*.coffee']

  grunt.initConfig
    coffee:
      src:
        files:
          'public/assets/striker.js' : 'src/striker.coffee'
      test:
        files:
          'public/tests/striker_test.js'         : 'test/striker_test.coffee'
          'public/tests/examples/test_helper.js' : 'test/examples/test_helper.coffee'
          'public/tests/examples/striker.js'     : ['test/examples/striker/*.coffee']

    tusk_coffee:
      current:
        options:
          root: 'examples'
        files:
          'public/assets/examples.js': examples

    docco:
      debug:
        src: ['src/striker.coffee']
        options:
          output: 'public/docs'

    coffeelint:
      app: ['src/*.coffee'].concat(examples)

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-docco')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-tusk-coffee')

  grunt.registerTask('test', ['coffee', 'tusk_coffee'])
  grunt.registerTask('default', ['coffee', 'coffeelint', 'docco'])
