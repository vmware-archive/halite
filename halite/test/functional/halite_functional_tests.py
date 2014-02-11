# -*- coding: utf-8 -*-

import config_helper
import bottle
import server_bottle
import time
import unittest
import webtest

from salt.client.api import APIClient


class HaliteFunctionalTestCase(unittest.TestCase):
    '''
    Tests for login / logout and some common responses
    '''

    def setUp(self):
        '''
        Login to Halite and store token
        '''
        app = bottle.Bottle()
        server_bottle.bottle = bottle
        server_bottle.createStaticMain()
        app = server_bottle.loadSaltApi(app)
        self.app = webtest.TestApp(app)
        test_info = config_helper.get_auth_info()
        self.tgt = config_helper.get_apache_minion()
        response = self.app.post_json('/login',
                                      dict(username=test_info['username'],
                                           password=test_info['password'],
                                           eauth='pam'))
        self.headers = {'X-Auth-Token': response.headers.get('X-Auth-Token')}

    def tearDown(self):
        '''
        Perform Logout
        '''
        self.app.post('/logout', headers=self.headers)

    def test_ping_returns_key(self):
        '''
        Basic test for test.ping data structure
        '''
        ping_response = self.app.post_json('/run',
                                           dict(tgt=self.tgt,
                                                client='minion',
                                                mode='sync',
                                                fun='test.ping'),
                                           headers=self.headers)
        self.assertNotEqual(ping_response.json_body.get('return',
                                                        None),
                            None)

    def test_ping_returns_minions(self):
        '''
        Test to check returned minions in test.ping data
        '''
        ping_response = self.app.post_json('/run',
                                           dict(tgt=self.tgt,
                                                client='minion',
                                                mode='sync',
                                                fun='test.ping'),
                                           headers=self.headers)
        minion = ping_response.json_body['return'][0].keys()[0]
        self.assertEqual(minion, self.tgt)

    def test_apache_status_up_returns_key(self):
        '''
        Test to start apache and check returned datastructure
        '''
        # make sure apache is up
        self.app.post_json('/run',
                           dict(tgt=self.tgt,
                                client='minion',
                                mode='sync',
                                fun='apache.signal',
                                kwarg=dict(signal='start')),
                           headers=self.headers)
        time.sleep(5)
        apache_response = self.app.post_json('/run',
                                             dict(tgt=self.tgt,
                                                  client='minion',
                                                  mode='sync',
                                                  fun='apache.server_status'),
                                             headers=self.headers)
        self.assertNotEqual(apache_response.json_body.get('return',
                                                          None),
                            None)

    def test_apache_status_up_returns_uptime(self):
        '''
        Ensure apache call returns uptime
        '''
        # make sure apache is up
        self.app.post_json('/run',
                           dict(tgt=self.tgt,
                                client='minion',
                                mode='sync',
                                fun='apache.signal',
                                kwarg=dict(signal='start')),
                           headers=self.headers)
        time.sleep(5)
        apache_response = self.app.post_json('/run',
                                             dict(tgt=self.tgt,
                                                  client='minion',
                                                  mode='sync',
                                                  fun='apache.server_status'),
                                             headers=self.headers)
        ret_val = apache_response.json_body['return'][0]
        minion = ret_val.keys()[0]
        self.assertNotEqual(ret_val[minion].get('Uptime',
                                                None),
                            None)

    def test_apache_status_down_returns_error(self):
        '''
        Ensure apache call returns uptime
        '''
        # make sure apache is down
        self.app.post_json('/run',
                           dict(tgt=self.tgt,
                                client='minion',
                                mode='sync',
                                fun='apache.signal',
                                kwarg=dict(signal='stop')),
                           headers=self.headers)
        time.sleep(5)
        apache_response = self.app.post_json('/run',
                                             dict(tgt=self.tgt,
                                                  client='minion',
                                                  mode='sync',
                                                  fun='apache.server_status'),
                                             headers=self.headers)
        ret_val = apache_response.json_body['return'][0]
        minion = ret_val.keys()[0]
        self.assertEqual(ret_val[minion], 'error')

    def runner_manage_present_async(self):
        '''
        Make a call to runner.manage.present and
        test against returned SSE data
        '''
        self.app.post_json('/run',
                           dict(client='master',
                                fun='runner.manage.present',
                                kwarg={}),
                           headers=self.headers)
        keep_looping = True
        client = APIClient()
        sse = None
        while keep_looping:
            sse = client.get_event(wait=5, tag='salt/', full=True)
            keep_looping = False
        self.assertNotEqual(sse, None)

    def runner_manage_present_datastructure(self):
        '''
        Make a call to runner.manage.present and
        test data structure integrity
        '''
        resp = self.app.post_json('/run',
                                  dict(client='master',
                                       fun='runner.manage.present',
                                       kwarg={}),
                                  headers=self.headers)
        tag = resp.json_body['return'][0]['tag']
        client = APIClient()
        data = None
        while not data:
            sse = client.get_event(wait=0.01, tag='salt/', full=True)
            if sse['tag'] == '%s/ret' % tag:
                data = sse['data']['return']
        self.assertNotEqual(data, None)

    def test_sys_doc_returns(self):
        '''
        Test that sys doc returns valid data
        '''
        doc_resp = self.app.post_json('/run',
                                      dict(tgt=self.tgt,
                                           client='minion',
                                           mode='sync',
                                           fun='sys.doc',
                                           arg=['test.ping']),
                                      headers=self.headers)
        self.assertNotEqual(doc_resp.json_body['return'][0][self.tgt],
                            None)

    def test_grains(self):
        '''
        Test grains call
        '''
        grains_resp = self.app.post_json('/run',
                                         dict(tgt=self.tgt,
                                              client='minion',
                                              mode='sync',
                                              fun='grains.items'),
                                         headers=self.headers)
        self.assertNotEqual(grains_resp.json_body['return'][0][self.tgt],
                            None)

if __name__ == '__main__':
    unittest.main()
