describe "Salt API Service Unit Tests", () ->

  $httpBackend = null
  SaltApiSrvc = null
  AppPref = null
  $scope = null

  beforeEach module "saltApiSrvc"

  beforeEach module "appPrefSrvc"

  afterEach () ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  beforeEach inject (_$rootScope_, _$httpBackend_, _SaltApiSrvc_, _AppPref_) ->
    $scope = _$rootScope_
    $httpBackend = _$httpBackend_
    SaltApiSrvc = _SaltApiSrvc_
    AppPref = _AppPref_

  it "calls success on run method success", () ->
    $httpBackend.whenPOST('/run').respond({success: true})
    i = 0
    SaltApiSrvc.run($scope, 'foo')
    .success () ->
        i = 1
    .error () ->
        i = 2
    $httpBackend.flush()
    expect(i).toBe(1)

  it "calls error on run method error", () ->
    $httpBackend.whenPOST('/run').respond(400, {success: false})
    i = 0
    SaltApiSrvc.run($scope, 'foo')
    .success () ->
        i = 1
    .error () ->
        i = 2
    $httpBackend.flush()
    expect(i).toBe(2)

  it "sets the proper error message on run method error", () ->
    $httpBackend.whenPOST('/run').respond(500, {error: 'fail'})
    SaltApiSrvc.run($scope, 'foo')
    $httpBackend.flush()
    expect($scope.errorMsg).toBe('Run Failed! fail')

  it "sets the proper error message on run method login fail", () ->
    $httpBackend.whenPOST('/run').respond(401, {error: 'fail'})
    SaltApiSrvc.run($scope, 'foo')
    $httpBackend.flush()
    expect($scope.errorMsg).toBe('Please Login! fail')

  it "calls success on action method success", () ->
    $httpBackend.whenPOST('/run').respond({success: true})
    $scope.command = {}
    $scope.command.history = {}
    $scope.command.humanize = jasmine.createSpy("humanize spy").andCallFake () ->
      return "SaltStack"
    i = 0
    SaltApiSrvc.action($scope, 'foo')
    .success () ->
        i = 1
    .error () ->
        i = 2
    $httpBackend.flush()
    expect(i).toBe(1)

  it "stores the last command on action method success", () ->
    $httpBackend.whenPOST('/run').respond({success: true})
    $scope.command = {}
    $scope.command.history = {}
    $scope.command.humanize = jasmine.createSpy("humanize spy").andCallFake () ->
      return "SaltStack"
    SaltApiSrvc.action($scope, 'foo')
    $httpBackend.flush()
    expect($scope.command.lastCmds).toBe("foo")

  it "stores command history on action method success", () ->
    $httpBackend.whenPOST('/run').respond({success: true})
    $scope.command = {}
    $scope.command.history = {}
    $scope.command.humanize = jasmine.createSpy("humanize spy").andCallFake () ->
      return "SaltStack"
    SaltApiSrvc.action($scope, 'bar')
    $httpBackend.flush()
    expect($scope.command.history['SaltStack']).toBe("bar")

  it "stores the last command on action method error", () ->
    $httpBackend.whenPOST('/run').respond(500, {error: 'some_error'})
    $scope.command = {}
    $scope.command.history = {}
    $scope.command.humanize = jasmine.createSpy("humanize spy").andCallFake () ->
      return "SaltStack"
    SaltApiSrvc.action($scope, 'foo')
    $httpBackend.flush()
    expect($scope.command.lastCmds).toBe("foo")

  it "does not store command history on action method error", () ->
    $httpBackend.whenPOST('/run').respond(500, {error: 'some_error'})
    $scope.command = {}
    $scope.command.history = {}
    $scope.command.humanize = jasmine.createSpy("humanize spy").andCallFake () ->
      return "SaltStack"
    SaltApiSrvc.action($scope, 'bar')
    $httpBackend.flush()
    expect((key for own key of $scope.command.history).join()).toBe('')

  it "sets the proper error message on action method error", () ->
    $httpBackend.whenPOST('/run').respond(500, {error: 'fail'})
    $scope.command = {}
    $scope.command.history = {}
    $scope.command.humanize = jasmine.createSpy("humanize spy").andCallFake () ->
      return "SaltStack"
    SaltApiSrvc.action($scope, 'foo')
    $httpBackend.flush()
    expect($scope.errorMsg).toBe('Action Failed! fail')

  it "sets the proper error message on action method login fail", () ->
    $httpBackend.whenPOST('/run').respond(401, {error: 'fail'})
    $scope.command = {}
    $scope.command.history = {}
    $scope.command.humanize = jasmine.createSpy("humanize spy").andCallFake () ->
      return "SaltStack"
    SaltApiSrvc.action($scope, 'foo')
    $httpBackend.flush()
    expect($scope.errorMsg).toBe('Please Login! fail')

  it "calls success on login method success", () ->
    $httpBackend.whenPOST('/login').respond({success: true})
    i = 0
    SaltApiSrvc.login($scope, 'foo', 'bar')
    .success () ->
        i = 1
    .error () ->
        i = 2
    $httpBackend.flush()
    expect(i).toBe(1)

  it "calls error on login method error", () ->
    $httpBackend.whenPOST('/login').respond(400, {success: false})
    i = 0
    SaltApiSrvc.login($scope, 'foo', 'bar')
    .success () ->
        i = 1
    .error () ->
        i = 2
    $httpBackend.flush()
    expect(i).toBe(2)

  it "sets the proper error message on login method error", () ->
    $httpBackend.whenPOST('/login').respond(401, {error: 'fail'})
    SaltApiSrvc.login($scope, 'foo', 'bar')
    $httpBackend.flush()
    expect($scope.errorMsg).toBe('Login Failed!')

  it "calls success on logout method success", () ->
    $httpBackend.whenPOST('/logout').respond({success: true})
    i = 0
    SaltApiSrvc.logout($scope)
    .success () ->
        i = 1
    .error () ->
        i = 2
    $httpBackend.flush()
    expect(i).toBe(1)

  it "calls error on logout method error", () ->
    $httpBackend.whenPOST('/logout').respond(400, {success: false})
    i = 0
    SaltApiSrvc.logout($scope)
    .success () ->
        i = 1
    .error () ->
        i = 2
    $httpBackend.flush()
    expect(i).toBe(2)

  it "sets the proper error message on logout method error", () ->
    $httpBackend.whenPOST('/logout').respond(401, {error: 'fail'})
    SaltApiSrvc.logout($scope)
    $httpBackend.flush()
    expect($scope.errorMsg).toBe('Logout Failed!')
