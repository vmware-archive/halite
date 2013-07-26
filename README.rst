===========
Crystalline
===========

(Code-name) Crystalline is a Salt GUI. Status is pre-alpha. Contributions are
very welcome. Join us in #salt-devel on Freenode or on the salt-users mailing
list.

Installation quickstart
=======================

1.  Clone the Crystalline repository::

        git clone https://github.com/saltstack/crystalline

2.  Generate an ``index.html`` file::

        cd crystalline/halide
        ./genindex.py

3.  Install `salt-api`_ 0.8.2 or greater.
4.  Follow the instructions for configuring the `rest_cherrypy`_ module.
5.  Configure the ``app`` and ``static`` settings to point at the files in your
    crystalline clone. For example::

        rest_cherrypy:
          port: 8000
          debug: True
          static: /path/to/crystalline/halide
          app: /path/to/crystalline/halide/index.html

    .. note::

        The above configuration is for local use only and does not use HTTPS.
        Your Salt authentication credentials will be sent in the clear.

        Follow the `rest_cherrypy`_ module installation instructions to disable
        ``debug`` and generate self-signed SSL certiifcates, or use existing
        SSL certificates, for non-local usage.

6.  Start ``salt-api``::

        salt-api

7.  Open a browser and navigate to http://localhost:8000/app (substitute
    whatever ``port`` and ``app`` prefix you configured).

Documentation
=============

Browser requirements
--------------------

Support for ES5 and HTML5 is required. This means any modern browser or IE9+.

Server requirements
-------------------

* This app requires the `rest_cherrypy`_ module in ``salt-api`` to
  communicate with a running Salt installation via a REST API.
* The static media for this app is server-agnostic and may be served from any
  web server at a configurable URL prefix.
* This app uses the HTML5 history API and so the ``index.html`` should
  should be served from a base URL that otherwise ignores the rest of the URL
  path. In other words, if the base URL that serves the ``index.html`` file
  is ``/app``, then ``/app/some/path`` should also serve that same file.

Library requirements
--------------------

The development version uses Coffeescript, Karma, Jasmine, and others which are
all dependent on node.js.

Also one of the static content web servers provided uses express.js which is
also dependent on node.js.

First install nodejs and npm  using the package installers.
(http://nodejs.org/) Then do global installs of Coffeescript, Karma, Jasmine,
Express, Grunt-cli, Less etc

.. code-block:: bash

    $ sudo npm install -g coffee-script
    $ sudo npm install -g karma
    $ sudo npm install -g jasmine-node
    $ sudo npm install -g grunt-cli
    $ sudo npm install -g express
    $ sudo npm install -g less
    $ sudo npm install -g requirejs

To use express and/or grunt do a local installs of each. Any npm module that is
used locally via a require statement must be installed or linked locally.

.. code-block:: bash

    $ cd crystalline
    $ npm install express
    $ npm install grunt
    $ grunt

Halide is the code name for the pip install package that includes not only the
angular single page client side web application but also sample web servers for
serving up the initial web page loads.

The directory structure for the web application inside the Halide package
notionally is a customized layout tuned to the salt UI application. Notably it
follows some of the  latest thinking that the templates and controllers for
application views should be kept together.  The directory structure is as
folows::

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

Documentation
=============

Libraries Used
--------------

Client side web application requirements:

- AngularJS framework (http://angularjs.org/)
- Twitter Bootstrap Layout CSS (http://twitter.github.io/bootstrap/)
- AngularUI framwork (http://angular-ui.github.io/)
- Karma Test Runner (http://karma-runner.github.io/0.8/index.html)
- Jasmine unit test framework (http://pivotal.github.io/jasmine/)
- CoffeeScript Python/Ruby like javascript transpiler
  (http://coffeescript.org/)
- Express javascript web server
- Less css compiler

Running Application
-------------------

To run the included sample Express.js web server for the web application

.. code-block:: bash

  $ cd crystalline/halide/
  $ node server.js

To run the included sample web server for the web application

.. code-block:: bash

  $ cd crystalline/halide/
  $ python serving.py

To get command line options

.. code-block:: bash

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
any application specific .js and .css files from halide/app directory tree to
the main.html for the initial page load.

.. code-block:: bash

  $ python serving.py -d -g

Once the app code is stable an updated static app/main.html can be generated
with

.. code-block:: bash

  $ python serving.py -d -c

In production for a cached content delivery network with minified libraries
then generate the static app/main.html with

.. code-block:: bash

  $ python serving.py -c

And serve it with

.. code-block:: bash

  $ python serving.py -s cherrypy

or

.. code-block:: bash

  $ python serving.py -s gevent

Or some other more performant server

Testing
------------

To run the karma jasmine unit test runner

.. code-block:: bash

  $ cd crystalline
  $ karma start karma_unit.conf.js

To run the karma angular scenario e2e test runner first start up a web server.
A multithreaded or asynchronous one will be needed if more than one browser is
tested at once.

.. code-block:: bash

  $ cd crystalline
  $ python serving.py -d -g -s cherrypy
  $ karma start karma_e2e.conf.js

.. ............................................................................

.. _`crystalline`: https://github.com/saltstack/crystalline
.. _`salt-api`: https://github.com/saltstack/salt-api
.. _`rest_cherrypy`: http://salt-api.readthedocs.org/en/latest/ref/netapis/all/saltapi.netapi.rest_cherrypy.html
