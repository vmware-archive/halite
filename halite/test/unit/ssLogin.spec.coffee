describe "ssLogin directive", () ->
  $scope = null
  beforeEach module 'appDrtv'
  beforeEach module 'appStoreSrvc'
  element = null
  forms = null
  loginForm = null
  logoutForm = null
  SessionStore = null
  div = null
  span = null
  $httpBackend = null
  htmlTemplate = '''
  <ss-login>
    <div ng-show="!!loggedIn" />
    <span ng-show="!loggedIn" />
  </ss-login>
  '''


  beforeEach inject ($compile, $rootScope, _SessionStore_, _$httpBackend_) ->
    SessionStore = _SessionStore_
    SessionStore.set 'loggedIn', false
    $scope = $rootScope.$new()
    element = $compile(htmlTemplate)($scope)
    $scope.$digest()
    div = element.find('div')
    span = element.find('span')
    $httpBackend = _$httpBackend_
    return

  afterEach () ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()


  it "has logged in as false initially", () ->
    expect($scope.loggedIn).toBe(false)

  it "has logged in as false when SessionStore's login is undefined", () ->
    SessionStore.set 'loggedIn', undefined
    expect($scope.loggedIn).toBe(false)

  it "exposes loginUser function", () ->
    expect($scope.loginUser).not.toBe(undefined)

  it "exposes logoutUser function", () ->
    expect($scope.logoutUser).not.toBe(undefined)

  it "initially has no error messages defined", () ->
    expect($scope.errorMsg).toBe('')

  it "initially hides div", () ->
    expect(div.hasClass('ng-hide')).toBe(true)

  it "initially shows span", () ->
    expect(span.hasClass('ng-hide')).toBe(false)

  it "sets the right error message when login fails", () ->
    $scope.loginUser()
    $httpBackend.whenPOST('/login').respond(401, {success: false})
    $httpBackend.flush()
    expect($scope.errorMsg).not.toBe('')

  it "sets loggedIn to false when login fails", () ->
    $scope.loginUser()
    $httpBackend.whenPOST('/login').respond(401, {success: false})
    $httpBackend.flush()
    expect($scope.loggedIn).toBe(false)

  it "sets loggedIn to true when login is a success", () ->
    $scope.loginUser()
    $httpBackend.whenPOST('/login').respond(200, {"return": [{"username": "adi", "name": "adi", "perms": [".*", "@runner", "@wheel"], "start": 1396037152.103604, "token": "6e22a743d10b3607ffc9505f52f6157a", "expire": 1396080352.103605, "user": "adi", "eauth": "pam"}]})
    $httpBackend.flush()
    expect($scope.loggedIn).toBe(true)

  it "sets loggedIn to false when logout is a success", () ->
    $scope.loginUser()
    $httpBackend.whenPOST('/login').respond(200, {"return": [{"username": "adi", "name": "adi", "perms": [".*", "@runner", "@wheel"], "start": 1396037152.103604, "token": "6e22a743d10b3607ffc9505f52f6157a", "expire": 1396080352.103605, "user": "adi", "eauth": "pam"}]})
    $httpBackend.flush()
    expect($scope.loggedIn).toBe(true)
    $scope.logoutUser()
    $httpBackend.whenPOST('/logout').respond(200, {"return": [{"username": "adi", "name": "adi", "perms": [".*", "@runner", "@wheel"], "start": 1396037152.103604, "token": "6e22a743d10b3607ffc9505f52f6157a", "expire": 1396080352.103605, "user": "adi", "eauth": "pam"}]})
    $httpBackend.flush()
    expect($scope.loggedIn).toBe(false)
