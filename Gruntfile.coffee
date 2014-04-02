module.exports = (grunt) ->
  grunt.registerTask 'default', 'Try Logging', ->
    grunt.log.write('Running the default task')

  # Initialize the configuration.
  grunt.initConfig

    nggettext_extract:
      pot: {
      files: {
        'i18n/halite.pot': ['halite/app/*.html',
                            'halite/app/view/*.html']
        }
      },

    nggettext_compile: {
      all: {
        options: {
          module: 'MainApp'
        },
        files: {
          'i18n/translations.js': ['i18n/*.po']
        }
      },
    }

  # Load external Grunt task plugins.
  grunt.loadNpmTasks "grunt-angular-gettext"

  # Default task.
  grunt.registerTask "default", ["nggettext_extract", "nggettext_compile"]

