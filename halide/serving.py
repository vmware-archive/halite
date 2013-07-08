#!/usr/local/bin/python2.7

""" Runs wsgi web server using bottle framework
    
    To get usage
    
    $ python serving.py -h
    
    Runs embedded wsgi server when run directly as __main__.
    The server is at http://localhost:port or http://127.0.0.1:port
    The default port is 8080
    The root path is http://localhost:port
    and routes below are relative to this root path so
    "/" is http://localhost:port/
     
"""
import sys
import os
import argparse

import aiding


if __name__ == "__main__":
    """Process command line args """
    
    levels = aiding.LOGGING_LEVELS #map of strings to logging levels
    
    d = "Runs localhost wsgi service on given host address and port. "
    d += "\nDefault host:port is 0.0.0.0:8080."
    d += "\n(0.0.0.0 is any interface on localhost)"
    p = argparse.ArgumentParser(description = d)
    p.add_argument('-l','--level',
                    action='store',
                    default='info',
                    choices=levels.keys(),
                    help="Logging level.")
    p.add_argument('-s','--server', 
                    action = 'store',
                    nargs='?', 
                    const='wsgiref', 
                    default='wsgiref',
                    help = "Wsgi server type.")
    p.add_argument('-a','--host', 
                    action = 'store',
                    nargs='?', 
                    const='0.0.0.0', 
                    default='0.0.0.0',
                    help = "Wsgi server ip host address.")
    p.add_argument('-p','--port', 
                    action = 'store',
                    nargs='?', 
                    const='8080', 
                    default='8080',
                    help = "Wsgi server ip port.")    
    p.add_argument('-r','--reload',
                    action = 'store_const',
                    const = True,
                    default = False,
                    help = "Server reload mode if also in debug mode.")
    p.add_argument('-d','--devel',
                    action = 'store_const',
                    const = True,
                    default = False,
                    help = "Development mode.")
    p.add_argument('-g','--gen',
                    action = 'store_const',
                    const = True,
                    default = False,
                    help = "Generate main.html dynamically.")
    p.add_argument('-c','--create',
                    action = 'store',
                    nargs='?', 
                    const = 'app/main.html',
                    default = '',
                    help = "Create app/main.html (default) or given file and quit.")
    p.add_argument('-b','--base',
                    action = 'store',
                    nargs='?', 
                    const = '/halide',
                    default = '/halide',
                    help = "Base Url for client side web application.")     

    args = p.parse_args()
    
    logger = aiding.getLogger(name="Halide", level=levels[args.level])
    
    if args.create:
        logger.info("Creating %s" % args.create)
        path = os.path.abspath(args.create)
        import ending
        ending.logger.setLevel(levels[args.level]) # set bottle app logger from args
        ending.development = args.devel         
        ending.createStaticMain(path=path, base=args.base)
        sys.exit()
    
    if args.server in ['gevent']:
        try:
            import gevent
            from gevent import monkey
            monkey.patch_all()
        except ImportError as ex: #gevent support not available
            args.server = 'wsgiref' # use default server
    
    
    import bottle
    
    
    logger.info("Running web application with server %s on %s:%s" %
                (args.server, args.host, args.port))
    
    if args.devel:
        logger.info("Running in development mode")
    logger.info("Logger %s at level %s." % (logger.name, args.level))
    
    #inject dependencies before using app
    import ending  #bottle app file
    
    ending.logger.setLevel(levels[args.level]) # set bottle app logger from args
    
    ending.development = args.devel 
    ending.generate = args.gen
    ending.baseprefix = args.base
    ending.remount(base=args.base)
    from ending import app
     
    bottle.run( app=app,
                server=args.server,
                host=args.host,
                port=args.port,
                debug=args.devel, 
                reloader=args.reload, 
                interval=1,
                quiet=False)
