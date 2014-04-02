Lattice
=======

SaltStack Common UI code

What is Lattice
---------------

Lattice is Saltstack GUI common repo. Lattice includes Javascript code to present interface to salt and HTML / CSS to bootstrap an app. Javascript components provide an interface to Salt and store the data model. Information such as Jobs, Events, Minions, Commands for example. This data model can be consumed by a front end.


Contrubutions
-------------

Lattice was extracted from [Halite](https://github.com/saltstack/halite) and owes thanks to the [contributions](https://github.com/saltstack/halite/graphs/contributors) made there.


Libraries
---------

Lattice also includes [libraries](https://github.com/saltstack/lattice/tree/master/lib). Any updates to shared libraries can be made here.

Lattice code updates
--------------------

Lattice's subtree might be updated by git subtree pull as shown by the example ``git subtree pull --prefix=halite/lattice lattice master --squash``. 

Lattice might be updated from a "parent" repo by executing ``git subtree split --prefix=halite/lattice -b my_branch`` followed by ``git push lattice my_branch:my_lattice_branch``.
