
// Karma configuration
module.exports = function(config) {
  config.set({
  
    // base path, that will be used to resolve files and exclude
    basePath: 'halite/',
    
    // compile coffee scripts
    preprocessors: {'**/*.coffee': 'coffee' },
    
    
        // New in karma v10
    frameworks: ["jasmine"],
    
    // list of files / patterns to load in the browser
    files: [
      //'lib/angular/angular-loader.js',
      'lib/angular/angular.js',
      'lib/angular/angular-animate.js',
      'lib/angular/angular-route.js',
      'lib/angular/angular-resource.js',
      'lib/angular/angular-cookies.js',
      'lib/angular/angular-sanitize.js',
      'lib/angular/angular-touch.js',
      'lib/angular/angular-mocks.js',
      'lib/underscore/underscore.js',
      'lib/underscore/underscore.string.js',
      'app/**/*.js',
      'test/unit/**/*.spec.coffee',
      'test/unit/**/*.spec.litcoffee',
      'test/unit/**/*.spec.js'
    ],
    

    
    // list of files to exclude
    exclude: ["test/e2e/*"],
    
    
    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit'
    reporters: ['progress'],
    
    
    // web server port
    port: 9876,
    
    
    // cli runner port
    runnerPort: 9100,
    
    
    // enable / disable colors in the output (reporters and logs)
    colors: true,
    
    
    // level of logging
    // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO,
    
    
    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,
    

    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['PhantomJS', 'Chrome', 'Safari', 'Firefox'],
    
    
    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,
    
    
    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false,
    
    // Map karma specific pages to not conflict with proxy server
    urlRoot: "/__karma/"


  });
};