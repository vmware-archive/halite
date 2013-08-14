#!/usr/local/bin/python2.7

""" Runs wsgi web server using bottle framework
    
    To get usage
    
    $ python server_bottle.py -h
    
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
import time
import datetime
import hashlib

try:
    import simplejson as json
except ImportError as ex:
    import json


import aiding

logger = aiding.getLogger(name="Bottle")

# Web application specific static files
STATIC_APP_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'app')

# Third party static web libraries
STATIC_LIB_PATH =  os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lib')



def loadWebUI(app):
    """ Load endpoints for bottle app"""
        
    #catch all for page refreshes of any app url
    @app.route('/app/<path:path>') # /app/<path>
    @app.route('/app/') # /app/
    @app.route('/app') # /app
    @app.route('/') # /
    def appGet(path=''):
        return bottle.static_file('main.html', root=STATIC_APP_PATH)  
        
    @app.route('/static/app/<filepath:path>')
    def staticAppGet(filepath):
        return bottle.static_file(filepath, root=STATIC_APP_PATH)
    
    @app.route('/static/lib/<filepath:path>')
    def staticLibGet(filepath):
        return bottle.static_file(filepath, root=STATIC_LIB_PATH)
    
    @app.get('/test') 
    def testGet():
        """ Test endpoint for bottle application
            Shows location of this file
            shows all routes in current bottle app
        """
        bottle.response.set_header('content-type', 'text/plain')
        content =  "Web app file is located at %s" % os.path.dirname(os.path.abspath(__file__))
        siteMap = ""
        
        currentApp = bottle.app()
        
        for route in currentApp.routes:
            siteMap = "%s%s%s %s" %  (siteMap, '\n' if siteMap else '', route.rule, route.method)
            target = route.config.get('mountpoint', {}).get('target')
            if target:
                for way in target.routes:
                    siteMap = "%s\n    %s %s" %  (siteMap, way.rule, way.method)
                    
        content = "%s\n%s" %  (content, siteMap)
        return content
    
    
    @app.get('/echo')
    @app.get('/echo/<action>')
    def echoGet(action=None):
        """ Ajax test endpoint for web application service
            Echos back query args and content
        """
        #convert to json serializible dict
        query = { key: val for key, val in bottle.request.query.items()}
        
        data = dict(verb='GET',
                    url=bottle.request.url,
                    action=action,
                    query=query,
                    content=bottle.request.json)
    
        return data
    
    @app.get('/ping') 
    def pingGet():
        """ Send salt ping"""
        import salt.client
        import salt.config
        __opts__ = salt.config.client_config(
                    os.environ.get('SALT_MASTER_CONFIG', '/etc/salt/master'))
        local = salt.client.LocalClient(__opts__['conf_file'])
        local.cmd('*', 'test.ping',  username="saltwui", password='dissolve', eauth='pam')
        
        return dict(result = "Sent Ping")
    
    @app.get('/stream/basic')
    def streamBasicGet():
        """ Create server sent event stream with counter"""
        bottle.response.set_header('Content-Type',  'text/event-stream') #text
        bottle.response.set_header('Cache-Control',  'no-cache')
        # Set client-side auto-reconnect timeout, ms.
        yield 'retry: 100\n\n'
        yield 'data: START\n\n'
        n = 1
        end = time.time() + 600 # Keep connection alive no more then... (s)
        while time.time() < end:
            yield 'data: %i\n\n' % n
            n += 1
            gevent.sleep(1.0) if gevented else time.sleep(1.0)
            
        yield "data: END\n\n"
        
def tokenify(cmd, token=None):
    """ If token is not None Then assign token to 'token' key of dict cmd and return cmd
        Otherwise return cmd
    """
    if token is not None:
        cmd['token'] = token
    return cmd

def loadSaltApi(app):
    '''
    Load endpoint for Salt-API
    '''
    from salt.exceptions import EauthAuthenticationError
    import salt.client.api
    #import salt.auth
    #import salt.config
    #import salt.utils
    #import saltapi
    #_opts = salt.config.client_config(
                    #os.environ.get('SALT_MASTER_CONFIG', '/etc/salt/master'))
    
    sleep = gevent.sleep if gevented else time.sleep
    
    corsRoutes = ['/login', '/logout',
                  '/', '/act', '/act/<token>',
                  '/run', 'run/<token>',
                  '/events/<token>']
    
    @app.hook('after_request')
    def enableCors():
        """ Add CORS headers to each response
            Don't use the wildcard '*' for Access-Control-Allow-Origin in production.
        """
        #bottle.response.set_header('Access-Control-Allow-Credentials', 'true')
        bottle.response.set_header('Access-Control-Max-Age:', '3600')
        bottle.response.set_header('Access-Control-Allow-Origin', '*')
        bottle.response.set_header('Access-Control-Allow-Methods',
                            'PUT, GET, POST, DELETE, OPTIONS')
        bottle.response.set_header('Access-Control-Allow-Headers', 
            'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token, X-Auth-Token')
    
    @app.route(corsRoutes, method='OPTIONS')
    def allowOption(path=None):
        """ Respond to OPTION request method
        """
        return {}
    
    @app.post('/login') 
    def loginPost():
        """ Login and respond with login credentials"""
        data = bottle.request.json
        if not data:
            bottle.abort(400, "Login data missing.")        
        
        creds = dict(username=data.get("username"),
                     password=data.get("password"),
                     eauth=data.get("eauth"))
        
        client = salt.client.api.APIClient()
        try:
            creds = client.create_token(creds)
        except IOError as ex:
            import  sys, traceback
            print ''.join(traceback.format_exception(*sys.exc_info()))
            if ex.errno == 13:
                bottle.abort(403, "Insufficient permissions.")
            else:
                raise
        except Exception as ex:
            bottle.abort(400, text=repr(ex))
            
        if not 'token' in creds:
            bottle.abort(401, "Authentication failed with provided credentials.") 
            
        bottle.response.set_header('X-Auth-Token', creds['token'])
        
        
        creds['user'] = creds['name']

        return {"return": [creds]} 
    
    @app.post('/logout') 
    def logoutPost():
        """ Logout
            {return: "Logout suceeded."}
        """
        token = bottle.request.get_header('X-Auth-Token')
        if token:
            result = {"return": "Logout suceeded."}
        else:
            result = {}
        return result
    
    @app.post('/signature')
    @app.post('/signature/<token>')
    def signaturePost(token = None):
        """ Fetch module function signature(s) with either credentials in post data
            or token from url or token from X-Auth-Token header
        """
        if not token:
            token = bottle.request.get_header('X-Auth-Token')
        
        cmds = bottle.request.json
        if not cmds:
            bottle.abort(code=400, text='Missing command(s).')
            
        if hasattr(cmds, 'get'): #convert to array
            cmds =  [cmds]
        
        client = salt.client.api.APIClient()
        try:
            results = [client.signature(tokenify(cmd, token)) for cmd in cmds]
        except EauthAuthenticationError as ex:
            bottle.abort(code=401, text=repr(ex))
        except Exception as ex:
            bottle.abort(code=400, text=repr(ex))            
            
        return {"return": results}
    
    @app.post('/') 
    @app.post('/act')
    @app.post('/act/<token>')
    @app.post('/run')
    @app.post('/run/<token>')
    def runPost(token = None):
        """ Execute salt command with either credentials in post data
            or token from url or token from X-Auth-Token headertoken 
        """
        if not token:
            token = bottle.request.get_header('X-Auth-Token')
        
        cmds = bottle.request.json
        if not cmds:
            bottle.abort(code=400, text='Missing command(s).')
            
        if hasattr(cmds, 'get'): #convert to array
            cmds =  [cmds]
        
        client = salt.client.api.APIClient()
        try:
            results = [client.run(tokenify(cmd, token)) for cmd in cmds]
        except EauthAuthenticationError as ex:
            bottle.abort(code=401, text=repr(ex))
        except Exception as ex:
            bottle.abort(code=400, text=repr(ex))            
            
        return {"return": results}   
    
    @app.post('/') 
    @app.post('/act')
    @app.post('/act/<token>')
    @app.post('/run')
    @app.post('/run/<token>')
    def runPost(token = None):
        """ Execute salt command with token from X-Auth-Token header """
        if not token:
            token = bottle.request.get_header('X-Auth-Token')
        
        cmds = bottle.request.json
        if not cmds:
            bottle.abort(code=400, text='Missing command(s).')
            
        if hasattr(cmds, 'get'): #convert to array
            cmds =  [cmds]
        
        client = salt.client.api.APIClient()
        try:
            results = [client.run(tokenify(cmd, token)) for cmd in cmds]
        except EauthAuthenticationError as ex:
            bottle.abort(code=401, text=repr(ex))
        except Exception as ex:
            bottle.abort(code=400, text=repr(ex))            
            
        return {"return": results}     
        
    @app.get('/event/<token>')
    @app.get('/events/<token>')
    def eventGet(token):
        """
            Create server sent event stream from salt
            and authenticate with the given token
        """
        if not token:
            bottle.abort(401, "Missing token.")
        
        client = salt.client.api.APIClient()
        
        if not client.verify_token(token): #auth.get_tok(token):
            bottle.abort(401, "Invalid token.")
        
        bottle.response.set_header('Content-Type',  'text/event-stream') #text
        bottle.response.set_header('Cache-Control',  'no-cache')
    
        # Set client-side auto-reconnect timeout, ms.
        yield 'retry: 100\n\n'
    
        while True:
            data =  client.get_event(wait=0.025, full=True)
            if data:
                yield 'data: {0}\n\n'.format(json.dumps(data))
            else:
                sleep(0.1)
    
    @app.post('/fire')            
    @app.post('/fire/<token>')
    def firePost(token=None):
        """
            Fire event(s)
            Each event is a dict of the form
            {
              tag: 'tagstring',
              data: {datadict},
            }
            Post body is either list of events or single event
        """
        if not token:
            token = bottle.request.get_header('X-Auth-Token')        
        if not token:
            bottle.abort(401, "Missing token.")
        
        client = salt.client.api.APIClient()
        
        if not client.verify_token(token): #auth.get_tok(token):
            bottle.abort(401, "Invalid token.")
        
        events = bottle.request.json
        if not events:
            bottle.abort(code=400, text='Missing event(s).')
        
        if hasattr(events, 'get'): #convert to list if not
            events = [events]
        
        results = [dict(tag=event['tag'],
                        result=client.fire_event(event['data'], event['tag']))
                   for event in events]
        
        bottle.response.set_header('Content-Type',  'application/json')
        return json.dumps(results)
        
    
    return app

def loadErrors(app):
    """ Load decorated Error functions for bottle web application
        Error functions do not automatically jsonify dicts so must manually do so.
    """

    @app.error(400)
    def error400(ex):
        bottle.response.set_header('content-type', 'application/json')
        return json.dumps(dict(error=ex.body))
    
    @app.error(401)
    def error401(ex):
        bottle.response.set_header('content-type', 'application/json')
        return json.dumps(dict(error=ex.body))    
    
    @app.error(404)
    def error404(ex):
        """ Use json 404 if request accepts json otherwise use html"""
        if 'application/json' not in bottle.request.get_header('Accept', ""):
            bottle.response.set_header('content-type', 'text/html')
            return bottle.tonat(bottle.template(bottle.ERROR_PAGE_TEMPLATE, e=ex))
        
        bottle.response.set_header('content-type', 'application/json')    
        return json.dumps(dict(error=ex.body))
    
    @app.error(405)
    def error405(ex):
        bottle.response.set_header('content-type', 'application/json')
        return json.dumps(dict(error=ex.body))
    
    @app.error(409)
    def error409(ex):
        bottle.response.set_header('content-type', 'application/json')
        return json.dumps(dict(error=ex.body))

def remount(base):
    """ Remount current app to new app at base mountpoint such as '/demo'
        This enables different root path such as required by web server proxy
    """
    if not base: # no remount needed
        return bottle.app()
    oldApp = bottle.app.pop() # remove current app
    newApp = bottle.app.push() # create new app
    newApp.mount(base, oldApp) # remount old on new path
    return newApp

def rebase(base):
    """ Create new app using current app routes prefixed with base"""
    if not base: #no rebase needed
        return bottle.app()
    
    oldApp = bottle.app.pop()
    newApp = bottle.app.push()
    for route in oldApp.routes:
        route.rule = "{0}{1}".format(base, route.rule)
        newApp.add_route(route)
        route.reset() #reapply plugins on next call
    return newApp

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
    p.add_argument('-b','--base',
                    action = 'store',
                    nargs='?', 
                    const = '',
                    default = '',
                    help = "Base Url for client side web application.")    
    
    args = p.parse_args()
    
    logger.setLevel(levels[args.level])
    gevented = False
    if args.server in ['gevent']:
        try:
            import gevent
            from gevent import monkey
            monkey.patch_all()
            gevented = True
        except ImportError as ex: #gevent support not available
            args.server = 'wsgiref' # use default server
    
    
    import bottle
    
    app = bottle.default_app() # create bottle app
    
    loadErrors(app)
    loadWebUI(app)
    loadSaltApi(app)
    #app = remount(base=args.base)
    app = rebase(base=args.base)
    
    logger.info("Running web application with server %s on %s:%s" %
                    (args.server, args.host, args.port))    
     
    bottle.run( app=app,
                server=args.server,
                host=args.host,
                port=args.port,
                debug=True, 
                reloader=False, 
                interval=1,
                quiet=False)
