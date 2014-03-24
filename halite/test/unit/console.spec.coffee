# jasmine

describe 'Console Controller Spec', () ->

    $scope = null
    $httpBackend = null
    virtualenv_create = null
    sys_doc = null
    test_echo = null
    disk_usage = null
    test_ping = null
    runner_manage_status = null
    Itemizer = null
    Minioner = null
    ErrorReporter = null
    JobDelegate = null
    docs =
        'test.ping': 'foo'
        'network.ping': 'bar'

    beforeEach module('MainApp')

    beforeEach inject ($rootScope, $controller, _$httpBackend_, _Itemizer_, _Minioner_, _ErrorReporter_, _JobDelegate_) ->
        $scope = $rootScope.$new()
        Itemizer = _Itemizer_
        Minioner = _Minioner_
        $httpBackend = _$httpBackend_
        ErrorReporter = _ErrorReporter_
        JobDelegate = _JobDelegate_
        docKeys = ['test.ping', 'network.ping']

        $controller 'ConsoleCtlr',
            $scope: $scope

        $scope.docKeys = docKeys
        $scope.docs = docs

        command = {}
        command.cmd = {}
        $scope.command = command
        _virtualenv_create = '{"compute.home":{"virtualenv.create":{"kwargs":null,"args":["path","venv_bin","no_site_packages","system_site_packages","distribute","clear","python","extra_search_dir","never_download","prompt","pip","symlinks","upgrade","runas","saltenv"],"defaults":[null,null,false,false,false,null,null,null,null,false,null,null,null,"base"],"varargs":null}},"compute.vm":{"virtualenv.create":{"kwargs":null,"args":["path","venv_bin","no_site_packages","system_site_packages","distribute","clear","python","extra_search_dir","never_download","prompt","pip","symlinks","upgrade","runas"],"defaults":[null,null,false,false,false,null,null,null,null,false,null,null,null],"varargs":null}}}'
        _sys_doc = '{"compute.home":{"sys.doc":{"kwargs":null,"args":null,"defaults":null,"varargs":true}},"compute.vm":{"sys.doc":{"kwargs":null,"args":null,"defaults":null,"varargs":true}}}'
        _test_echo = '{"compute.home":{"test.echo":{"kwargs":null,"args":["text"],"defaults":null,"varargs":null}},"compute.vm":{"test.echo":{"kwargs":null,"args":["text"],"defaults":null,"varargs":null}}}'
        _disk_usage = '{"compute.home":{"disk.usage":{"kwargs":null,"args":["args"],"defaults":[null],"varargs":null}},"compute.vm":{"disk.usage":{"kwargs":null,"args":["args"],"defaults":[null],"varargs":null}}}'
        _test_ping = '{"compute.home":{"test.ping":{"kwargs":null,"args":null,"defaults":null,"varargs":null}},"compute.vm":{"test.ping":{"kwargs":null,"args":null,"defaults":null,"varargs":null}}}'
        _runner_manage_status = '{"master":{"manage.status":{"kwargs":null,"args":["output"],"defaults":[true],"varargs":null}}}'
        virtualenv_create = JSON.parse(_virtualenv_create)
        sys_doc  = JSON.parse(_sys_doc)
        test_echo = JSON.parse(_test_echo)
        disk_usage = JSON.parse(_disk_usage)
        test_ping = JSON.parse(_test_ping)
        runner_manage_status = JSON.parse(_runner_manage_status)


    it 'parses the right required argspec for test.echo', () ->
        $scope.command.cmd.fun = 'test.echo'
        argSpec = $scope.extractArgSpec(test_echo)
        expect(argSpec['required'].join('')).toBe('text')

    it 'parses the right default argspec for test.echo', () ->
        $scope.command.cmd.fun = 'test.echo'
        argSpec = $scope.extractArgSpec(test_echo)
        expect(argSpec['defaults']).toBe(null)

    it 'parses the right required argspec for sys.doc', () ->
        $scope.command.cmd.fun = 'sys.doc'
        argSpec = $scope.extractArgSpec(sys_doc)
        expect(argSpec['required'].length).toBe(0)

    it 'parses the right default argspec for sys.doc', () ->
        $scope.command.cmd.fun = 'sys.doc'
        argSpec = $scope.extractArgSpec(sys_doc)
        expect(argSpec['defaults']).toBe(null)

    it 'parses the right required argspec for disk.usage', () ->
        $scope.command.cmd.fun = 'disk.usage'
        argSpec = $scope.extractArgSpec(disk_usage)
        expect(argSpec['required'].length).toBe(0)

    it 'parses the right default argspec for disk.usage', () ->
        $scope.command.cmd.fun = 'disk.usage'
        argSpec = $scope.extractArgSpec(disk_usage)
        expect(argSpec['defaults'].length).toBe(1)

    it 'should perform case insensitive search', () ->
        $scope.command.cmd.fun = 'tEsT.PiNg'
        $scope.docSearch = true
        $scope.searchDocs()

        expect($scope.docSearchResults).toBe('test.ping\n' + docs['test.ping'] + '\n')

    it 'should perform exhaustive search', () ->
        $scope.command.cmd.fun = 'ping'
        $scope.docSearch = true
        $scope.searchDocs()


        expect($scope.docSearchResults).toContain('network')
        expect($scope.docSearchResults).toContain('test')

    it 'should perform correct search', () ->
        $scope.command.cmd.fun = 'network.ping'
        $scope.docSearch = true
        $scope.searchDocs()

        expect($scope.docSearchResults).not.toContain('test.ping')
        expect($scope.docSearchResults).toContain($scope.docs['network.ping'])

    it 'should clear test results when query is empty', () ->
        $scope.command.cmd.fun = 'network.ping'
        $scope.docSearch = true
        $scope.searchDocs()

        $scope.command.cmd.fun =  ''
        $scope.searchDocs()

        expect($scope.docSearchResults).toBe('')

    it 'should clear test results when query is undefined', () ->
        $scope.command.cmd.fun = 'network.ping'
        $scope.docSearch = true
        $scope.searchDocs()

        $scope.command.cmd.fun =  undefined
        $scope.searchDocs()

        expect($scope.docSearchResults).toBe('')

    it 'should clear test results when searchDocs is false', () ->
        $scope.command.cmd.fun = 'network.ping'
        $scope.docSearch = false
        $scope.searchDocs()

        expect($scope.docSearchResults).toBe('')
