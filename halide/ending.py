""" Endpoints for web server application to support Halide client side web app
    Uses bottle.py web framework

"""
import sys
from os import path

try:
    import simplejson as json
except ImportError as ex:
    import json
    
import bottle

try:
    import mustache
except ImportError as ex:
    pass
    
import aiding

logger = aiding.getLogger(name='Ending')

""" Bottle application and globals"""

app = bottle.default_app() # create bottle app
development = False # development mode means use non minified javascript libraries
generate = False # generate main.html dynamically

""" Decorated Error functions for bottle web application
    Error methods do not automatically jsonify dicts so must manually do so.
"""

@app.error(400)
def error400(ex):
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


""" Test endpoint for bottle application """
@app.get('/test') 
def testGet():
    """ Show location of this file and also show all routes"""
    bottle.response.set_header('content-type', 'text/plain')
    content =  "Web app file is located at %s" % path.dirname(path.abspath(__file__))
    siteMap = ""
    
    for route in app.routes:
        siteMap = "%s%s%s %s" %  (siteMap, '\n' if siteMap else '', route.rule, route.method)
        target = route.config.get('mountpoint', {}).get('target')
        if target:
            for way in target.routes:
                siteMap = "%s\n    %s %s" %  (siteMap, way.rule, way.method)
                
    content = "%s\n%s" %  (content, siteMap)
    return content

""" Ajax test endpoint for web application demoService """
@app.get('/demo')
@app.get('/demo/<action>')
def demoGet(action=None):
    """ Show location of this file and also show all routes"""
    
    #convert to json serializible dict
    query = { key: val for key, val in bottle.request.query.items()}
    
    data = dict(verb='GET',
                url=bottle.request.url,
                action=action,
                query=query,
                content=bottle.request.json)
    
    return data

""" Static files """

MAIN_TEMPLATE_PATH = path.join(path.dirname(path.abspath(__file__)), 'mold', 'main.html')

# Web application specific static files
STATIC_APP_PATH = path.join(path.dirname(path.abspath(__file__)), 'app')

# Third party static web libraries
STATIC_LIB_PATH =  path.join(path.dirname(path.abspath(__file__)), 'lib')

BASE_PATH = '/halide' # application base url path

if not generate or not 'mustache' in sys.modules: #use static file
    #catch all for page refreshes of any app url
    @app.route('/app/<path:path>') # /app/<path>
    @app.route('/app') # /app
    @app.route('/') # /
    def appGet(path=''):
        return bottle.static_file('main.html', root=STATIC_APP_PATH)
else: # dynamically generate using mustache
    #catch all for page refreshes of any app url
    @app.route('/app/<path:path>') # /app/<path>
    @app.route('/app') # /app
    @app.route('/') # /
    @mustache.template(MAIN_TEMPLATE_PATH)
    def appGet(path=''):
        data = dict(baseUrl=BASE_PATH, mini=".min" if not development else "")
        #if development: #add devMode copy of data to enable devMode only parts
            #data = dict(devMode=data, **data)
        return data
    
@app.route('/static/lib/<filepath:path>')
def staticAppGet(filepath):
    return bottle.static_file(filepath, root=STATIC_LIB_PATH)

@app.route('/static/app/<filepath:path>')
def staticLibGet(filepath):
    return bottle.static_file(filepath, root=STATIC_APP_PATH)


""" remount app to be behind BASE_PATH to enable different root path such as proxy
    app.mount(BASE_PATH, app) 
    http://localhost:8080/demo/test
"""


old = bottle.app.pop() # get current app
app = bottle.app.push() # create new app
app.mount(BASE_PATH, old) # remount old on new path
