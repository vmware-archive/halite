#!/usr/bin/env python
'''
A small script to run a template through Jinja and write the result to the
filesystem
'''
import optparse
import os
import sys

import jinja2

import aiding

logger = aiding.getLogger(name=__file__)

def parse_args():
    '''
    Process command line args
    '''
    levels = aiding.LOGGING_LEVELS #map of strings to logging levels

    p = optparse.OptionParser(description=__doc__)
    p.add_option('-l', '--level',
                    action='store',
                    default='info',
                    choices=levels.keys(),
                    help="Logging level.")
    p.add_option('-d', '--devel',
                    action='store_true',
                    default=False,
                    help="Development mode.")
    p.add_option('-c', '--create',
                    action='store',
                    default='app/main.html',
                    help="Create app/main.html (default) or given file and quit.")
    p.add_option('-b', '--base',
                    action='store',
                    default='/halide/static',
                    help="Base URL for client side web application.")
    p.add_option('-a', '--app',
                    action='store',
                    default='app',
                    help="Directory containing the app (JS/CSS) files.")
    p.add_option('-t', '--tmpl',
                    action='store',
                    default='mold/main.html',
                    help="Location of the template file to render.")
    p.add_option('-C', '--coffee',
                    action='store_true',
                    default=False,
                    help="When -g or -c configure main.html to compile coffeescript.")

    return p.parse_args()

def load_tmpl(filename):
    '''
    Load a template from the file system

    Default base path is the directory containing this script
    '''
    loader = jinja2.FileSystemLoader([
        os.path.abspath(os.path.dirname(__file__)),
    ])

    env = jinja2.Environment(loader=loader)
    return env.get_template(filename)

def main():
    '''
    Render a template from the filesystem and write the result to stdout
    '''
    opts, args = parse_args()

    logger.setLevel(opts.level.upper())

    appdir = os.path.join(os.path.abspath(os.path.dirname(__file__)), opts.app)

    scripts, stylesheets = aiding.getFiles(
            appdir,
            '', # handle the prefixing in the template
            coffee=opts.coffee)

    context = {
        'baseUrl': opts.base,
        'mini': '.min' if not opts.devel else '',
        'scripts': scripts,
        'stylesheets': stylesheets,
        'coffee': opts.coffee,
    }

    template = load_tmpl(opts.tmpl)

    if opts.create == '-':
        sys.stdout.write(template.render(context))
    else:
        logger.info("Creating {0}".format(opts.create))

        with open(opts.create, 'w+') as fp:
            fp.write(template.render(context))

if __name__ == '__main__':
    raise SystemExit(main())
