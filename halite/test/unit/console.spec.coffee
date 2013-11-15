# jasmine

describe 'Console Controller Search Functionality', () ->

    $scope = null
    $httpBackend = null

    docs =
        'test.ping': 'foo'
        'network.ping': 'bar'

    beforeEach module('MainApp')

    beforeEach inject ($rootScope, $controller, _$httpBackend_) ->
        $scope = $rootScope.$new()
        $httpBackend = _$httpBackend_

        docKeys = ['test.ping', 'network.ping']

        $controller 'ConsoleCtlr',
            $scope: $scope

        $scope.docKeys = docKeys
        $scope.docs = docs

        command = {}
        command.cmd = {}
        $scope.command = command

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

    it 'submits a job and calls startJob in fetchDocs', () ->
      $httpBackend.whenPOST('/run').respond({return: [true]})
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      $scope.fetchDocs()
      $scope.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: jasmine.createSpy('commitSpy').andCallFake () ->
            obj2 =
              then: jasmine.createSpy('thenSpy')
        return obj
      $httpBackend.flush()
      expect($scope.startJob).toHaveBeenCalled()

    it 'submits a job and calls commit on job in fetchDocs', () ->
      $httpBackend.whenPOST('/run').respond({return: [true]})
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      $scope.fetchDocs()
      commitSpy = jasmine.createSpy('commitSpy').andCallFake () ->
        obj2 =
          then: jasmine.createSpy('thenSpy')
      $scope.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: commitSpy
        return obj
      $httpBackend.flush()
      expect(commitSpy).toHaveBeenCalled()

    it 'calls success callback on success in fetchDocs', () ->
      $httpBackend.whenPOST('/run').respond({return: [true]})
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      $scope.fetchDocs()
      $scope.fetchDocsDone = jasmine.createSpy('fetchDocsDone spy')
      commitSpy = jasmine.createSpy('commitSpy').andCallFake ($q) ->
        defer = $q.defer()
        defer.resolve('foo')
        return defer.promise
      $scope.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: commitSpy
        return obj
      $httpBackend.flush()
      expect($scope.fetchDocsDone).toHaveBeenCalled()

    it 'calls error callback on error in fetchDocs', () ->
      $httpBackend.whenPOST('/run').respond({return: [true]})
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      $scope.fetchDocs()
      $scope.fetchDocsFailed = jasmine.createSpy('fetchDocsFailed spy')
      commitSpy = jasmine.createSpy('commitSpy').andCallFake ($q) ->
        defer = $q.defer()
        defer.reject('foo')
        return defer.promise
      $scope.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: commitSpy
        return obj
      $httpBackend.flush()
      expect($scope.fetchDocsFailed).toHaveBeenCalled()

    it 'sets an error message in fetchDocsFailed method', () ->
      $scope.errorMsg = null
      $scope.fetchDocsFailed()
      expect($scope.errorMsg).not.toBeNull()
