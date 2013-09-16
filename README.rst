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

1. Setup permissions for users who will use Halite
For example in master config:
  
.. code-block:: bash  
  saltwui:
      - .*
      - '@runner'
      - '@wheel'

  Halite uses the runner manage.status to get the status of minions so runner
  permissions are required.  Currently halite allows but does not require any 
  wheel modules.

2.  Clone the Halite repository::

.. code-block:: bash

  git clone https://github.com/saltstack/halite


3. Run halite/halite/server_bottle.py (use with -h option to get parameters)
   The simplest approach is to run the server with it dynamically generating
   the main web app load page (main.html) in coffescript mode, where the coffeescript
   is transpiled to javascript on the fly. In each case the appropriate server package
   must be installed.
   
.. code-block:: bash
  
    $ ./server_bottle.py -d -C -l debug -s cherrypy
    
    $ ./server_bottle.py -d -C -l debug -s paste

    $ ./server_bottle.py -d -C -l debug -s gevent
    


4. Navigate html5 compliant browser to http://localhost:8080/app

6. Login

The default eauth method is 'pam'. To change go to the preferences page.

Documentation
=============

Preferences
-----------

Click on the SaltStack logo to go to the preferences page

.. image:: screenshots/Preferences.png

On this page one can change the eauth method to something other than 'pam' such
as 'ldap'.
Enter the new eauth method string into the field saltApi.eauth and hit update.
Now refresh the browser page and the new eauth method will be enabled. Login.
  
Commands
----------

To navigate to the console view click on the 'console' tab. 

.. image:: screenshots/HomeConsole.png

The top section of the Console view has controls for entering basic salt commands.
The target field will target minions with the command selected. There is ping button
with the bullhorn icon and the action menu has some preselected common commands.

Expanded Commands
-----------------

.. image:: screenshots/CommandForm.png

Click on the downward chevron button to expand the command form with additional
fields for entering any salt module function. To enter "runner" functions prepend
"runner." to the function name. For example, "runner.manage.status". To enter wheel
functions prepend "wheel." to the wheel function name. For example, "wheel.config.values".
For commands that require arguments enter them in the arguments fiels. Click the "plus"
button to add addition arguments.
Click on the Execute button or press the Return key to execute the command.

Monitors
---------
 
The bottom section of the console view has monitor view buttons. Each button will
show panels with the associated information.

* Command Monitor

Shows panels, one per command that has been executed by this user on this console. 
Clicking on a panel will expand to show the associated job ids that have been 
run with this command and the  completion status via an icon. 
Red is fail, Green is success.
Clicking on the button on the panel will rerun the command.
  
.. image:: screenshots/CommandMonitor.png
  
* Job Monitor

Shows panels, one per job that has been run by any minion associated with this
master. Clicking on the panel with expand to show Result and Event tabs.
Selecting the result tab will show the returner and return data
for each minion targeted by the job.
  
.. image:: screenshots/JobMonitor.png

Selecting the Event tab will show the events associated with the job.
  
.. image:: screenshots/JobMonitorEvent.png
  
* Minion Monitor

Shows panels, one per minion that have keys associated with this master. The minion
panels have icons to show the up/down status of the minion and the grains status.
Selecting tabs will show grains data as well as minion (not job) generated events.
  
.. image:: screenshots/MinionMonitor.png
  
* Event Monitor

Shows panels, one per event associated with this Master.
  
.. image:: screenshots/EventMonitor.png
  
More Details comming. TBD


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

Optional dependencies: 

* Cherrypy web server (http://http://www.cherrypy.org/)
* Paste web server (http://pythonpaste.org/)
* Gevent web server(http://www.gevent.org/)

For nodejs testing:

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
