#!/usr/bin/env python

'''
Prepare halite for setup.py to build pip distribution

Transpile coffeescript files in javascript files
Create main.html
'''
import sys
import os
from subprocess import call

from halite.server_bottle import createStaticMain, HALITE_DIR_PATH

sys.stdout.write('Transpiling coffeescript ...\n')
retcode = call(['coffee', '-c', 'halite/lattice/app'  ])

if retcode:
    sys.stderr.write('Error transpiling coffeescript. Return code = {0}!'.format(retcode))
    sys.exit(1)

sys.stdout.write('Generating main.html ...\n')
load = os.path.abspath(os.path.normpath(os.path.join(HALITE_DIR_PATH, 'lattice/app/main.html')))
createStaticMain(   kind='bottle',
                    base='',
                    devel=False,
                    coffee=False,
                    save=True,
                    path=load)

sys.stdout.write('Finished.\n')
