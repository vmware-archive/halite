======
Halite
======

(Code-name) Halite is a Salt GUI. Status is pre-alpha. Contributions are
very welcome. Join us in #salt-devel on Freenode or on the salt-users mailing
list.

This is version 0.0.3 which is substantially changed from the previous version.
Any application based on the previous version will be broken.

This version is substantially different. Notable changes include:
1. Use of a new unified api in salt/client/api.py for talking to salt.
   Does not use Salt-API. The rest service is integral to halite.
2. Use of Server Sent Events (SSE) to receive realtime streaming of events 
  from the Salt Event Bus.
3. Use of Bottle web framework included with choice of WSGI web servers. The server must
  be multithreaded or gevented or the equivalent in order to support SSE. The tested
  servers are paste, cherrypy, and gevent
4. Simplified web API that is a thin wrapper around salt/client/api.py

This version of Halite is meant to work out of the box with an install option for 
SaltStack. The PyPi  (PIP) version of Halite is a minified version that is meant
to be installed along side Salt to provide a minimal out of the box UI for Salt.

The repository is meant for development of custom versions of the UI that would
be deployed with different servers, different configurations, etc and for development
of future features for the Salt packaged version.

Installation quickstart
=======================

1.  Clone the Halite repository::

        git clone https://github.com/saltstack/halite


2. Run halite/halite/server_bottle.py (use with -h option to get parameters)
   The simplest approach is to run the server with it dynamically generating
   the main web app load page (main.html) in coffescript mode, where the coffeescript
   is transpiled to javascript on the fly. In each case the appropriate server package
   must be installed.
   
.. code-block:: bash
  
    $ ./server_bottle.py -d -C -l debug -s cherrypy
    
    $ ./server_bottle.py -d -C -l debug -s paste

    $ ./server_bottle.py -d -C -l debug -s gevent
    



3. Navigate html5 compliant browser to http://localhost:8080/app


More Details comming. TBD

Documentation
=============

.. image:: screenshots/HomeConsole.png
.. image:: screenshots/CommandForm.png
.. image:: screenshots/JobMonitor.png
.. image:: screenshots/JobMonitorEvent.png
.. image:: screenshots/MinonMonitor.png
.. image:: screenshots/EventMonitor.png
.. image:: screenshots/Preferences.png

Browser requirements
--------------------

Support for ES5 and HTML5 is required. This means any modern browser or IE10+.

Server requirements
-------------------

* The static media for this app is server-agnostic and may be served from any
  web server at a configurable URL prefix.
* This app uses the HTML5 history API.

Libraries used
--------------

Client side web application requirements:

* AngularJS framework (http://angularjs.org/)
* Bootstrap layout CSS (http://twbs.github.io/bootstrap/)
* AngularUI framework (http://angular-ui.github.io/)
* Underscore JS module (http://underscorejs.org/‎)
* Underscore string JS module (http://epeli.github.io/underscore.string/)
* Font Awesome Bootstrap Icon Fonts  (http://fortawesome.github.io/Font-Awesome/)
* CoffeeScript Python/Ruby like javascript transpiler (http://coffeescript.org/)
* Karma Test Runner (http://karma-runner.github.io/0.8/index.html)
* Jasmine unit test framework (http://pivotal.github.io/jasmine/)

Optional dependencies 
* Cheerypy web server (http://http://www.cherrypy.org/)
* Paste web server (http://pythonpaste.org/)
* Gevent web server(http://www.gevent.org/)

For nodejs testing
* Express javascript web server



Testing
-------

To run the karma jasmine unit test runner

.. code-block:: bash

  $ cd halite
  $ karma start karma_unit.conf.js

To run the karma angular scenario e2e test runner first start up a web server.
A multithreaded or asynchronous one will be needed if more than one browser is
tested at once.

.. code-block:: bash

  $ cd halite
  $ karma start karma_e2e.conf.js

.. ............................................................................

.. _`halite`: https://github.com/saltstack/halite
