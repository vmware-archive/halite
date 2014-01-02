# -*- coding: utf-8 -*-

import ConfigParser
import os


def get_config():
    '''
    Instantiate parser and read file.
    Returns: parser
    '''
    config = ConfigParser.SafeConfigParser()
    config.read('./halite/test/functional/config/testing.conf')
    if os.path.exists('./halite/test/functional/config/override.conf'):
        config.read('./halite/test/functional/config/override.conf')
    return config


def get_auth_info():
    '''
    Returns credentials
    '''
    config = get_config()
    return {'username': config.get('login', 'username'),
            'password': config.get('login', 'password')}


def get_apache_minion():
    '''
    Returns minion for apache status operations
    '''
    return get_config().get('minions', 'apache')
