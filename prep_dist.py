#!/usr/bin/env python

''' 
Prepare halite for setup.py to build pip distribution

Transpile coffeescript files in javascript files
Create main.html
'''
import sys
from subprocess import call

sys.stdout.write('Transpiling coffeescript ...\n')
retcode = call(['coffee', '-c', 'halite/app'  ])

if retcode:
    sys.stderr.write('Error tranpiling coffeescript. Return code = {0}!'.format(retcode))
    sys.exit(1)

sys.stdout.write('Generating main.html ...\n')
retcode = call(['halite/server_bottle.py', '-g', '-f', 'app/main.html' ])

if retcode:
    sys.stderr.write('Error generating main.html. Return code = {0}!'.format(retcode))
    sys.exit(1)    

sys.stdout.write('Finished.\n')