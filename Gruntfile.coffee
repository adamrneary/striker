module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'tmp/striker.js'     : 'src/striker.coffee'
          'tmp/application.js' : 'src/examples/application.coffee'
          'tmp/modules.js'     : ['src/examples/**/*.coffee']

    docco:
      debug:
        src: ['src/striker.coffee']
        options:
          output: 'public/docs'

    watch:
      scripts:
        files: ['src/**/*.coffee', 'Gruntfile.coffee', 'public/vendor/**/*']
        tasks: ['coffee', 'concat', 'docco']

    coffeelint:
      app: ['src/*.coffee', 'src/**/*.coffee']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-docco')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.registerTask('default', ['coffee', 'docco', 'concat', 'watch'])
