==================================
Installing Halite for Development
==================================

This document describes the steps necessary to install Halite for development.

Programming languages used are

* Python (2.7)
* Coffeescript (1.8)
* CSS
* HTML

Install Salt
------------

Please make sure that you have already installed salt master on your dev box. Halite requires the salt master to be running on the same machine.
Once you install salt please add your user to the ``external_auth`` section. Please use this (non root) user for logging in to Halite.

Install Halite Deps
-------------------

Please install ``nodejs`` (v0.10+) and ``npm``. Once you install npm please install coffee-script by doing ``npm install -g coffee-script``. Lastly install the ``paste`` server by running ``pip install paste``. 

Install Halite
--------------

Once you have the deps installed as stated above, you can clone the code and install it as shown below. Note: Please change the IP address below to your IP address.

.. code-block:: bash

  $ git clone git@github.com/Saltstack/halite.git
  $ pip install -e ./halite
  $ cd halite
  $ ./prep_dist.py  # Compiles coffee-script to Javascript
  $ ./halite/server_bottle.py -a 192.168.33.11 -p 8001 # starts halite

You can now navigate to http://192.168.33.11:8001/app to access Halite. More `options
<https://github.com/saltstack/halite/blob/e476b79583506e34c26cdd260eed0c24b9f15c5f/halite/server_bottle.py#L577-L634>`_ can be passed in to ``server_bottle.py``.

