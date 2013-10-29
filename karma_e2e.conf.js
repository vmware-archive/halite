// Karma configuration
module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: 'halite/',
    
        // compile coffee scripts
    preprocessors: {'**/*.coffee': 'coffee' },
    
    frameworks: ['ng-scenario'],
    
    // list of files / patterns to load in the browser
    files: [
      'test/e2e/**/*.spec.coffee',
      'test/e2e/**/*.spec.litcoffee',
      'test/e2e/**/*.spec.js'
    ],
    
    
    // list of files to exclude
    exclude: ['test/unit/*'],
    
    
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
    
    
    // Proxy server for end to end testing
    // Server must be running for tests to work
    proxies: { "/": "http://localhost:8080/" },
    
    
    // Map karma specific pages to not conflict with proxy server
    urlRoot: "/__karma/",
    

  });
};