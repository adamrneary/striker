module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      src:
        files:
          'public/assets/striker.js'             : 'src/striker.coffee'
          'public/assets/example_app.js'         : 'src/examples/application.coffee'
          'public/assets/example_collections.js' : ['src/examples/collections/*.coffee']
          'public/assets/example_views.js'       : ['src/examples/views/*.coffee']
      test:
        files:
          'tmp/striker_test.js'        : 'test/striker_test.coffee'
          'tmp/example_test_helper.js' : 'test/examples/test_helper.coffee'
          'tmp/example_tests.js'       : ['test/examples/**/*.coffee']

    docco:
      debug:
        src: ['src/striker.coffee']
        options:
          output: 'public/docs'

    coffeelint:
      app: ['src/*.coffee', 'src/**/*.coffee']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-docco')
  grunt.loadNpmTasks('grunt-coffeelint')

  grunt.registerTask('default', ['coffee', 'coffeelint', 'docco'])
