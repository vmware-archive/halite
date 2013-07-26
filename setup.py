""" setup.py
    Basic setup file to enable pip install
    See http://python-distribute.org/distribute_setup.py
    
    
    python setup.py register sdist upload 

"""

from setuptools import setup, find_packages

setup(
    name = 'halite',
    version = '0.0.1',
    description = 'SaltStack Web UI',
    url = 'https://github.com/saltstack/halite',
    packages = find_packages(exclude=[]),
    package_data={'': ['*.txt',  '*.ico',  '*.json', '*.md', '*.conf', ''
                       '*.js', '*.html', '*.css', '*.png',]},
    install_requires = [],
    extras_require = {},
    tests_require = ['nose'],
    test_suite = 'nose.collector',
    author='SaltStack Inc',
    author_email='info@saltstack.com',
    license="Commercial",
    keywords='Salt Stack web client side application user interface',
)
