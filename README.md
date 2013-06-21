===========
Crystalline
===========

(Code-name) Crystalline is a Salt GUI.

Requirements
============

Support for ES5 is required. This means any modern browser or > IE9.


Installation Instructions
--------------------------

For buiding development version using Yeoman, Bower, Grunt, Karma
First install nodejs and npm


## Install Grunt, Bower, Yeoman, Karma and Generators

http://yeoman.io/
https://github.com/yeoman/generator-angular
https://github.com/yeoman/generator-angular.git

    $ sudo npm install -g grunt-cli
    $ sudo npm install -g bower
    $ sudo npm install -g karma
    $ sudo npm install -g yo
    $ sudo npm install -g generator-karma
    $ sudo npm install -g generator-mocha
    $ sudo npm install -g generator-webapp

Fix bug in prompt.js that is used by yeoman.

In these two files change as follows:

/usr/local/lib/node_modules/yo/node_modules/yeoman-generator/node_modules/prompt/lib/prompt.js
/usr/local/lib/node_modules/yo/node_modules/insight/node_modules/prompt/lib/prompt.js

    var events = require('events'),
        readline = require('readline'),
        utile = require('utile'),
        async = utile.async,
        /* capitalize = utile.inflect.capitalize, Changed Sam Smith 20130621 */
        capitalize = utile.capitalize,
        read = require('read'),
        validate = require('revalidator').validate,
        winston = require('winston');


## Now install angular generator
The standard install does not work
    
    $ sudo npm install -g generator-angular


Instead Download zip from git repo onto local file system unzip and then install from file

    $ sudo npm install -g /Users/samuel/Downloads/generator-angular-master 

Now verify that the generators are all there

    $ yo --help

Should show that karma one of the generators

Now build the angular skeleton. Goto the directory 

    $ cd /Volumes/Gob/Data/SaltStack/Code/crystalline


    $ yo angular  halide --coffee --minsafe 

Accept all the options
Now install the other libraries

    $ bower install angular-mocks           
    $ bower install angular-ui          
    $ bower install angular-strap
    $ bower install angular-ui-router

To test do this. Not working yet

    $ grunt test                        
    $ grunt server                      
    $ grunt         
