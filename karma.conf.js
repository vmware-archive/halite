// Karma configuration
// Generated on Wed Jun 26 2013 13:43:18 GMT-0600 (MDT)


// base path, that will be used to resolve files and exclude
basePath = 'halide/test/';


// list of files / patterns to load in the browser
files = [
  JASMINE,
  JASMINE_ADAPTER,
  '**/*.spec.coffee',
  '**/*.spec.litcoffee',
  '**/*.spec.js'
];


// list of files to exclude
exclude = [];


// test results reporter to use
// possible values: 'dots', 'progress', 'junit'
reporters = ['progress'];


// web server port
port = 9876;


// cli runner port
runnerPort = 9100;


// enable / disable colors in the output (reporters and logs)
colors = true;


// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_INFO;


// enable / disable watching file and executing tests whenever any file changes
autoWatch = true;

// compile coffee scripts
preprocessors = {'**/*.coffee': 'coffee' },

// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari (only Mac)
// - PhantomJS
// - IE (only Windows)
browsers = ['PhantomJS', 'Chrome', 'Safari', 'Firefox'];


// If browser does not capture in given timeout [ms], kill it
captureTimeout = 60000;


// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = false;
