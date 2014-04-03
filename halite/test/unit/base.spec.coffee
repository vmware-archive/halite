# jasmine

describe 'Base Controller Spec', () ->

    $scope = null
    $httpBackend = null
    Itemizer = null
    Minioner = null
    JobDelegate = null
    AppData = null

    beforeEach module('MainApp')

    beforeEach inject ($rootScope, $controller, _$httpBackend_, _Itemizer_, _Minioner_, _JobDelegate_, _AppData_) ->
        $scope = $rootScope.$new()
        Itemizer = _Itemizer_
        Minioner = _Minioner_
        $httpBackend = _$httpBackend_
        JobDelegate = _JobDelegate_
        AppData = _AppData_

        $controller 'BaseController',
            $scope: $scope

    it 'returns immediately when there are no minons', () ->
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
      expect($scope.startJob).not.toHaveBeenCalled()

    it 'submits a job and calls startJob in fetchDocs', () ->
      $httpBackend.whenPOST('/run').respond({return: [true]})
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      AppData.getMinions().set('A', new Minioner('A'))
      AppData.getMinions().set('B', new Minioner('B'))
      $scope.fetchDocs()
      JobDelegate.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: jasmine.createSpy('commitSpy').andCallFake () ->
            obj2 =
              then: jasmine.createSpy('thenSpy')
        return obj
      $httpBackend.flush()
      expect(JobDelegate.startJob).toHaveBeenCalled()

    it 'submits a job and calls commit on job in fetchDocs', () ->
      $httpBackend.whenPOST('/run').respond({return: [{'jid': 12345, 'minions': ['A']}]})
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      AppData.getMinions().set('A', new Minioner('A'))
      AppData.getMinions().set('B', new Minioner('B'))
      $scope.fetchDocs()
      commitSpy = jasmine.createSpy('commitSpy').andCallFake () ->
        obj2 =
          then: jasmine.createSpy('thenSpy')
      JobDelegate.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: commitSpy
        return obj
      $httpBackend.flush()
      expect(commitSpy).toHaveBeenCalled()

    it 'calls success callback on success in fetchDocs', () ->
      data = {}
      data.return = []
      dt =
        _data: 'foo'
      data.return.push dt
      $httpBackend.whenPOST('/run').respond(data)
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      AppData.getMinions().set('A', new Minioner('A'))
      AppData.getMinions().set('B', new Minioner('B'))
      $scope.fetchDocs()
      $scope.fetchDocsDone = jasmine.createSpy('fetchDocsDone spy')
      commitSpy = jasmine.createSpy('commitSpy').andCallFake ($q) ->
        defer = $q.defer()
        defer.resolve(data)
        return defer.promise
      JobDelegate.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: commitSpy
        return obj
      $httpBackend.flush()
      expect($scope.fetchDocsDone).toHaveBeenCalled()

    it 'calls error callback on error in fetchDocs', () ->
      data = {}
      data.return = []
      dt =
        _data: 'foo'
      data.return.push dt
      $httpBackend.whenPOST('/run').respond(data)
      $httpBackend.whenGET('/static/app/view/console.html').respond('')
      AppData.getMinions().set('A', new Minioner('A'))
      AppData.getMinions().set('B', new Minioner('B'))
      $scope.fetchDocs()
      $scope.fetchDocsFailed = jasmine.createSpy('fetchDocsFailed spy')
      commitSpy = jasmine.createSpy('commitSpy').andCallFake ($q) ->
        defer = $q.defer()
        defer.reject('foo')
        return defer.promise
      JobDelegate.startJob = jasmine.createSpy('startJob').andCallFake () ->
        obj =
          commit: commitSpy
        return obj
      $httpBackend.flush()
      expect($scope.fetchDocsFailed).toHaveBeenCalled()

    it 'sets an error message in fetchDocsFailed method', () ->
      $scope.fetchDocsFailed()
      expect($scope.alerts()).not.toBeNull()
