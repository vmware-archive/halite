0.1.0 (2013-09-24)
==================

Features
---------

* Upgraded to Twitter Bootstrap v 3.0
Cherrypicked and modified the following directives from UI-bootstrap to be compatible
with Bootsrap 3.0. Since UI-Bootstrap won't be fully BS3 compat until v 0.7

See halite/app/util/appDrtv.coffee

alert  -> ssAlert

dropDownToggle -> ssDropdownToggle


* Added new directive ssToggleUnion.
This adds new type of radio button like group called ToggleUnion
where at most one member can be selected but none is allowed

ssToggleUnion

* Clean up the display. 
Get rid of slats and use toggle unions instead of tabs for drill down display of monitor data

* Community additions of packages for Arch and Suse Linux

* Documentation updates



Bug Fixes
----------

* No change from 0.0.9


Breaking Changes
-----------------

* Anyone making a custom version of a halite application that used bootstrap 2 features
or UI-Bootstrap plugins will be broken.