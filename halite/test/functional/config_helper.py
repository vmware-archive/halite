# -*- coding: utf-8 -*-

import ConfigParser
import os


def get_file_names():
    '''
    Returns names of config and override file
    '''
    return (
        "/root/halite/halite/test/functional/config/testing.conf",
        "/root/halite/halite/test/functional/config/override.conf"
    )


def get_config():
    '''
    Instantiate parser and read file.
    Returns: parser
    '''
    config = ConfigParser.SafeConfigParser()
    config.read(get_file_names()[0])
    if os.path.exists(get_file_names()[1]):
        config.read(get_file_names()[1])
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
