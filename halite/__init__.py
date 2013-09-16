'''
halite package for Salt UI client side web application 
'''

# Import Python libs
import os


def start(hopts=None, debug=None):
    '''
    Wrapper to start up and run server. Reads in the master config and supplies
    halite parameters to configure the server.
    
    The server serves both the static content and provide
    the dynamic api to salt used by the web application. This is meant to be run
    by Salt to provide out of the box WUI capability. For different installations
    use the appropriate server executable file such as server_bottle.py
    '''
    import salt.config
    import salt.syspaths
    
    from .aiding import getLogger, LOGGING_LEVELS
    from . import server_bottle

    logger = getLogger(name="Halite", level=LOGGING_LEVELS['debug'] )    
    

    if not hopts:
        hopts = salt.config.client_config(
                    os.environ.get(
                        'SALT_MASTER_CONFIG',
                         os.path.join(salt.syspaths.CONFIG_DIR, 'master'))).get('halite')

    kwparms = {
            'level': 'info',
            'server': 'paste',
            'host': '0.0.0.0',
            'port': '8080',
            'cors': False,
            'tls': True,
            'certpath': '/etc/pki/tls/certs/localhost.crt',
            'keypath': '/etc/pki/tls/certs/localhost.key',
            'pempath': '/etc/pki/tls/certs/localhost.pem',
        }

    if hopts:
        for key in kwparms.keys():
            if key in hopts:
                kwparms[key] = hopts[key]
    
    if debug:
        logger.debug('Halite: Starting server with options. \n{0}'.format(kwparms))
    
    server_bottle.startServer(**kwparms)
