0.1.02 (2013-10-14)
==================

Features
----------

Command form now supports all target expression formats not just glob


Fixes
------

Changed fetchGrains on refresh to only fetch grains of active minions hopefully
fixes #42

prep_dist on arch  07c04ff5acf3975dadbf9bc6dd2fc5c25dc927aa

submit button behavior on command form was erratic with return now works


0.1.01 (2013-09-24)
==================

Features
---------
Added pagination to monitors


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