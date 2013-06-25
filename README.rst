===========
Crystalline
===========

(Code-name) Crystalline Project Directory is a Salt GUI.

Requirements
============

Web browser requirements.
Support for ES5 and HTML5 is required. This means any modern browser or > IE9.

Client side web application uses: 
AngularJS framework (http://angularjs.org/) 
Twitter Bootstrap Layout CSS (http://twitter.github.io/bootstrap/)
AngularUI framwork (http://angular-ui.github.io/)
Karma Test Runner (http://karma-runner.github.io/0.8/index.html)
Jasmine unit test framework (http://pivotal.github.io/jasmine/)
CoffeeScript Python/Ruby like javascript transpiler (http://coffeescript.org/)
among others


Installation Instructions
--------------------------

The development version uses Coffeescript, Karma, Jasmine, and others which are all
dependent on node.js.

Also one of the static content web servers provided uses express.js which is
also dependent on node.js.

First install nodejs and npm  using the package installers. (http://nodejs.org/)
Then do global installs of Coffeescript, Karma, Jasmine, Express, Grunt-cli

  $ sudo npm install -g coffee-script
  $ sudo npm install -g karma
  $ sudo npm install -g jasmine-node
  $ sudo npm install -g grunt-cli
  $ sudo npm install -g express

  $ sudo npm install -g requirejs


To use express and/or grunt do a local installs of each

  $ cd crystalline
  $ npm install express
  $ npm install grunt
  $ grunt
  
Halide is the code name for the pip install package that includes not only the angular 
single page client side web application but also sample web servers for serving 
up the initial web page loads. 

The directory structure for the web application inside the Halide package 
notionally is a customized layout tuned to the salt UI application. Notably it
follows some of the  latest thinking that the templates and controllers for 
application views should be kept together.  The directory structure is as folows:


  crystalline/
    LICENSE
    LICENSE.txt
    README.rst
    README.md
    setup.py  # python package setup
    Gruntfile.coffee #grunt conf file
    package.json # node package conf file
    bower.json # bower conf file
    
    node_modules/  # local node.js modules
  
  
  
    halide/
      __init__.py  # Python package file
  
      app/  # web application
        main.html  # entry point for single page web application
        main.css  # application specific design for web application
        main.coffee # main angular application module
        main.js  # transpiled version of main.coffee
        favicon.ico # application favicon
        robots.txt # robots.txt file
    
        view/   # html templates, controllers, styles for specific app views
          home.html
          home.coffee
          home.js
          home.css
    
        util/  # common support modules for application such as services, directives, and filters
          demoSrvc.coffee
          demoDrtv.coffee
          demoFltr.coffee
    
        rsrc/  # JSON resources or other assets such as images etc
  
      lib/ # Third party libraries for application such as angular etc
        angular/
        bootstrap/
        angular-unstable/
        angular-ui/
  
    test/  # unit and end to end (e2e) tests for the web application

Running Application
-------------------

To run the included sample Express.js web server for the web application

  $ cd crystalline/halide/
  $ node expressWs.js
  

To run the included sample Bottle.py web server for the web application

  $ cd crystalline/halide/
  $ python bottleWs.py
  
To get command line options

  $ python bottleWs.py -h
  
  usage: bottleWs.py [-h] [-l {info,debug,critical,warning,error}] [-s [SERVER]]
                   [-a [HOST]] [-p [PORT]] [-r] [-d]

  Runs localhost wsgi service on given host address and port. Default host:port
  is localhost:8080.
  
  optional arguments:
    -h, --help            show this help message and exit
    -l {info,debug,critical,warning,error}, --level {info,debug,critical,warning,error}
                          Logging level.
    -s [SERVER], --server [SERVER]
                          Wsgi server type.
    -a [HOST], --host [HOST]
                          Wsgi server ip host address.
    -p [PORT], --port [PORT]
                          Wsgi server ip port.
    -r, --reload          Server reload mode if also in debug mode.
    -d, --devel           Development mode.

