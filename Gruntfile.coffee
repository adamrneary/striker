module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      compile:
        files:
          'tmp/striker.js'     : 'src/striker.coffee'
          'tmp/application.js' : 'src/examples/application.coffee'
          'tmp/modules.js'     : ['src/examples/**/*.coffee']

    concat:
      js:
        src: [
          'public/vendor/js/jquery.js',
          'public/vendor/js/underscore.js',
          'public/vendor/js/backbone.js',
          'public/vendor/js/highcharts.js',
          'public/vendor/js/d3.js',
          'public/lib/js/tablestakes.js',
          'tmp/striker.js'
          'tmp/application.js'
          'tmp/modules.js'
        ],
        dest: 'public/assets/application.js'

      css:
        src: [
          'public/vendor/css/bootstrap.css',
          'public/lib/css/tablestakes.css',
          'src/examples/css/application.css'
        ],
        dest: 'public/assets/application.css'

    watch:
      scripts:
        files: ['src/**/*.coffee', 'Gruntfile.coffee']
        tasks: ['coffee', 'concat']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-docco')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.registerTask('default', ['coffee', 'concat', 'watch'])
