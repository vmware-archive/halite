Crystalline
===========

(Code-name) Crystalline Project Directory is a Salt GUI.

Requirements
============

Web browser requirements.
  - Support for ES5 and HTML5 is required. This means any modern browser or > IE9.

Client side web application requirements: 
  - AngularJS framework (http://angularjs.org/) 
  - Twitter Bootstrap Layout CSS (http://twitter.github.io/bootstrap/)
  - AngularUI framwork (http://angular-ui.github.io/)
  - Karma Test Runner (http://karma-runner.github.io/0.8/index.html)
  - Jasmine unit test framework (http://pivotal.github.io/jasmine/)
  - CoffeeScript Python/Ruby like javascript transpiler (http://coffeescript.org/)
  - Express javascript web server
  - Less css compiler

Local test web server
  - Uses bottle.py which is included. The default server is wsgiref which is single
    threaded. For multi-threaded support other web servers can be used if installed.
    Tested ones include paste, gevent, and cherrypy. For karma end to end testing
    of multiple browsers a multi-threaded or asynchronous server is required.
    
Installation Instructions
--------------------------

The development version uses Coffeescript, Karma, Jasmine, and others which are all
dependent on node.js.

Also one of the static content web servers provided uses express.js which is
also dependent on node.js.

First install nodejs and npm  using the package installers. (http://nodejs.org/)
Then do global installs of Coffeescript, Karma, Jasmine, Express, Grunt-cli, Less etc
```bash
  $ sudo npm install -g coffee-script
  $ sudo npm install -g karma
  $ sudo npm install -g jasmine-node
  $ sudo npm install -g grunt-cli
  $ sudo npm install -g express
  $ sudo npm install -g less
  $ sudo npm install -g requirejs
```

To use express and/or grunt do a local installs of each. Any npm module that is
used locally via a require statement must be installed or linked locally.

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
        SaltStack-Logo.png
    
        view/   # html templates, controllers, styles for specific app views
          home.html
          home.coffee
          home.js
          home.css
          ...
    
        util/  # common support modules for application such as services, directives, and filters
          demoDrtv.coffee
          demoDrtv.js
          demoFltr.coffee
          demoFltr.js
          demoSrvc.coffee
          demoSrvc.js
          metaSrvc.coffee
          metaSrvc.js
          
    
        rsrc/  # JSON resources or other assets such as images etc
  
      lib/ # Third party libraries for application such as angular etc
        angular/
        bootstrap/
        angular-unstable/
        angular-ui/
  
    test/  # unit and end to end (e2e) tests for the web application
      unit/ # jasmine unit test spec files
      e2e/ # angular scenario runner test spec files

Running Application
-------------------

To run the included sample Express.js web server for the web application

  $ cd crystalline/halide/
  $ node server.js
  

To run the included sample web server for the web application

  $ cd crystalline/halide/
  $ python serving.py 
  
To get command line options

  $ python serving.py -h
  usage: serving.py [-h] [-l {info,debug,critical,warning,error}] [-s [SERVER]]
                    [-a [HOST]] [-p [PORT]] [-r] [-d] [-g] [-c [CREATE]]
  
  Runs localhost wsgi service on given host address and port. Default host:port
  is 0.0.0.0:8080. (0.0.0.0 is any interface on localhost)
  
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
    -g, --gen             Generate main.html dynamically.
    -c [CREATE], --create [CREATE]
                          Create app/main.html (default) or given file and quit.

The recommended options for development are -d and -g. The last option will add
any application specific .js and .css files from halide/app directory tree
to the main.html for the initial page load.

  $ python serving.py -d -g

Once the app code is stable an updated static app/main.html can be generated with

  $ python serving.py -d -c
  
  
In production for a cached content delivery network with minified libraries then
generate the static app/main.html with
  $ python serving.py -c
  
And serve it with

  $ python serving.py -s cherrypy

or

  $ python serving.py -s gevent
  
Or some other more performant server

Testing
------------

To run the karma jasmine unit test runner

  $ cd crystalline
  $ karma start karma_unit.conf.js
  

To run the karma angular scenario e2e test runner first start up a web server. A
multithreaded or asynchronous one will be needed if more than one browser is
tested at once.

  $ cd crystalline
  $ python serving.py -d -g -s cherrypy
  $ karma start karma_e2e.conf.js