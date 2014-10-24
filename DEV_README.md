Halite Job Execution
====================

This document describes how Halite’s front end code executes Salt jobs.

The main parts of Halite and which are responsible for enabling job execution are

* [APIClient](https://github.com/saltstack/salt/blob/50d51e76e08dae125cdcb5554bb0968daed09308/salt/client/api.py#L43) - A Python class (salt.utils.APIClient) to programmatically interface with Salt
* [Server side end points](https://github.com/saltstack/halite/blob/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/server_bottle.py>) exposed by server_bottle.py
* [Front end](https://github.com/saltstack/halite/tree/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/lattice) AngularJS app provided through Lattice

APIClient
---------

One of the (Python) classes responsible for providing a programmatic interface to Salt. Halite’s server side code interfaces with Salt using ``APIClient``. Functionality provided by the APIClient includes authentication, running salt execution modules and listening for events on the salt master’s event bus. The purpose of such an interface is to enable command and control of your infrastructure using a GUI / client or a third party interface. Halite serves as a prototype GUI to explore these ideas.

End Points
----------

These end points are exposed over HTTP and provide the following methods / urls among others


* [/login](https://github.com/saltstack/halite/blob/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/server_bottle.py#L162) for sending the credentials and getting a token
* [/run](https://github.com/saltstack/halite/blob/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/server_bottle.py#L221) for running a salt command by passing in low data and and authentication token
* [/event](https://github.com/saltstack/halite/blob/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/server_bottle.py#L250) provides an event stream that lets us listen to Salt’s event bus

Front end app
-------------

Following steps are performed by Halite when it loads


* [Open the event stream](https://github.com/saltstack/halite/blob/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/lattice/app/view/base.coffee#L356) and establish a connection to Salt
* When the event stream is opened Halite makes a [call to the runner manage.present](https://github.com/saltstack/halite/blob/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/lattice/app/view/base.coffee#L91) and queries for connected minions.
* Once connected minions are known grains are fetched for these
* System documentation (sys.doc) is fetched
* Other optional information (jobs in the cache) is fetched and high state status checks are queued.

Once the above process is complete, the following information is present on the client side

* Minions
* Jobs
* Commands
* Events (that occurred since we opened the event stream)
* Docs

The above information is maintained on the client side, all of it (except docs) is tracked and updated in real time by Halite. This tracking is performed by listening to events and updating the above variables / data structures as events happen. We’ll cover more about event processing in a subsequent tutorial.

Let’s go back to our original objective of trying to execute salt commands asynchronously and being able to get our hands on the result and look at an example. In this example we’ll be going through Highstate checker’s code. The highstate checker executes state.highstate test=True by passing in low data to salt. The high state call is asynchronously executed. We’ll also be discussing any event callbacks that are required to process event results asynchronously. 
                                                                  
The code that we are interested in is [highstateCheckSrvc.coffee’s makeHighStateCall function](https://github.com/saltstack/halite/blob/754a45ed3b5e44d7b951004dd2fc0d3d4d651f17/halite/lattice/app/util/highstateCheckSrvc.coffee#L58-L86). 

* On line number 61 we obtain a list of connected minions.
* Lines 63-68 are responsible for building the low data that we’ll need to pass to salt for executing the function state.highstate test=True, on the given target.
* Line 70 causes the actual HTTP call to be made to the /run end point. At this point if everything is ok Salt responds with a JID. The functions beginning on lines 71 and 81 deal with the success and error callbacks for the HTTP call.
* In the success callback for the HTTP return we have a JID that was generated in response to this high state job (the job is not yet complete). On line number 74 we update the system state and add an entry for this job to the list of jobs Halite maintains. On line number 75 we see a call to the ``then`` method where functions are attached to be called when the highstate test=True job eventually finishes (a return event for this JID is seen on the event bus). We pass a success and an error function so that both the possible cases are handled.

So the following sequence of events is typical when executing jobs through Halite.

* Make a call to the /run end point with the low data
* Salt responds with a JID for this job
* Attach a second level of callbacks (based on the returned JID) that are triggered in response to a return (/ret) event for this JID. The ``ret`` event can be seen on the event bus.

