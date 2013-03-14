module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'public/assets/striker.js'     : 'src/striker.coffee'
          'public/assets/application.js' : 'src/examples/application.coffee'
          'public/assets/modules.js'     : ['src/examples/**/*.coffee']

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
