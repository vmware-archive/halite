""" setup.py
    Basic setup file to enable pip install
    See http://python-distribute.org/distribute_setup.py


    python setup.py register sdist upload

"""

from setuptools import setup, find_packages

pkg_files = [
              'app/*.txt',
              'app/*/*.txt',
              'app/*.ico', 'app/*/*.ico',
              'app/*.png', 'app/*/*.png',
              'app/*.html', 'app/*/*.html',
              'app/*.css', 'app/*/*.css',
              'app/*.js', 'app/*/*.js',
              'lib/*/*.png','lib/*/*/*.png',
              'lib/*/*.woff', 'lib/*/*/*.woff',
              'lib/angular/*.min.js', 'lib/angular/*.min.js.map',
              'lib/angular/i18n/*',
              'lib/angular/angular-loader.js',
              'lib/angular-ui/bootstrap/*-tpls.min.js',
              'lib/angular-ui/router/*.min.js',
              'lib/angular-ui/utils/*.min.js',
              'lib/bootstrap/js/*.min.js', 'lib/bootstrap/css/*.min.css',
              'lib/font-awesome/css/*.min.css',
              'lib/underscore/*.min.js', 'lib/underscore/*.min.map',
            ]
pkg_files = ['lattice/{0}'.format(x) for x in pkg_files]
setup(
    name = 'halite',
    version = '0.1.17',
    description = 'SaltStack Web UI',
    url = 'https://github.com/saltstack/halite',
    author='SaltStack Inc',
    author_email='info@saltstack.com',
    license='Apache V2.0',
    keywords='Salt Stack client side web application, web server',
    packages = find_packages(exclude=['*.mold', '*.mold.*',
                                      'test', 'tests.*',
                                      'node_*', 'node_*.*',
                                      'screenshots', 'screenshots.*']),
    package_data={
        '':       ['*.txt',  '*.md', '*.rst', '*.json', '*.conf', '*.html',
                   '*.css', '*.ico', '*.png', '../LICENSE'],
        'halite': pkg_files},
    install_requires = [''],
    extras_require = {}, )
