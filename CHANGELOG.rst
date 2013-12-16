0.1.12 (2013-12-16)
==================

Features
--------

Bug fixes
--------
Fix problem with installer

0.1.11 (2013-12-16)
==================

Features
--------
Show name as label and default value as placeholder for parameters having default values.

Bug fixes
--------
Clear old parameters when a new command is found

0.1.10 (2013-12-13)
==================

Features
--------

Bug fixes
--------
Fixed argspec parsing for some inputs (thanks to Dave Boucha)

0.1.09 (2013-12-13)
==================

Features
--------
Fetch cached jobs and show under job subtab after Halite loads
Dynamically change number of inputs to be the same as that required by the function
Validate form on valid target, function and it's required inputs
Have just one text box to enter function
Make command box collapsible
Changes to icon placements and display
Rename `master_config` to `opts` for consistency (thanks to Pedro Algarvio)
Call manage.present instead of manage.status (thanks to Sam Smith)

Bug fixes
--------
Pass the master opts up to Salt API initialization (thanks to Pedro Algarvio and Sam Smith)

0.1.08 (2013-11-27)
==================

Features
--------
Added progress bars for individual jobs
Added aggregate progress bars

Bug fixes
--------
Support for change in return semantics
Fixed checkbox

0.1.07 (2013-11-18)
==================

fixed pypi dist



0.1.06 (2013-11-18)
==================

Fixed typo in setup.py



0.1.05 (2013-11-18)
==================

Features
--------
Added display of state run progress events to the Job->Results view
Each minion result line now shows number of state run out of total with progress
bar. Run number badges show success or failure. Comment line is also shown




0.1.04 
========

Minor fixes


0.1.03 (2013-11-1)
==================

Features
----------

Command form now has search docs feature, where it displays the Salt docs associated
with a search string


Fixes
------

Updated karma test confs to support v 0.10.x of Karma
Workaround to tok problem introduced in 17.1
Packaging updates


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
