module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      src:
        files:
          'public/assets/striker.js' : 'src/striker.coffee'
      test:
        files:
          'public/tests/striker_test.js' : 'test/striker_test.coffee'

    docco:
      debug:
        src: ['src/striker.coffee']
        options:
          output: 'public/docs'

    coffeelint:
      app: ['src/*.coffee', 'examples/*.coffee', 'examples/**/*.coffee', 'examples/**/**/*.coffee']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-docco')
  grunt.loadNpmTasks('grunt-coffeelint')

  grunt.registerTask('default', ['coffee', 'coffeelint', 'docco'])
