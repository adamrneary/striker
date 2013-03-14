module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'public/assets/striker.js'             : 'src/striker.coffee'
          'public/assets/example_app.js'         : 'src/examples/application.coffee'
          'public/assets/example_collections.js' : ['src/examples/collections/*.coffee']
          'public/assets/example_views.js'       : ['src/examples/views/*.coffee']
      test:
        files:
          'tmp/striker_test.js'  : 'test/striker_test.coffee'
          'tmp/example_tests.js' : ['test/examples/**/*.coffee']

    docco:
      debug:
        src: ['src/striker.coffee']
        options:
          output: 'public/docs'

    watch:
      scripts:
        files: ['src/**/*.coffee']
        tasks: ['coffee', 'docco']

    coffeelint:
      app: ['src/*.coffee', 'src/**/*.coffee']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-docco')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.registerTask('default', ['coffee', 'docco', 'watch'])
