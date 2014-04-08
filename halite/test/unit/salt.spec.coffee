describe "Salt Service Unit Tests", () ->

  Salt = null
  $httpBackend = null
  Runner = null
  Item = null
  Resulter = null
  $rootScope = null
  JobDelegate = null
  AppData = null
  Minioner = null
  Jobber = null
  $q = null

  beforeEach module "MainApp"

  beforeEach inject (_Salt_, _$httpBackend_, _Runner_, _Item_, _Resulter_, _$rootScope_, _AppData_, _Minioner_, _$q_) ->
    $q = _$q_
    Salt = _Salt_
    $httpBackend = _$httpBackend_
    Runner = _Runner_
    Item = _Item_
    Resulter = _Resulter_
    $rootScope = _$rootScope_
    AppData = _AppData_
    Minioner = _Minioner_

  afterEach () ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'Gets a reference to salt', () ->
    expect(Salt).not.toBeNull()

  it 'Fetches minions on boot', () ->
    defer = $q.defer()
    data = new Runner('20140408134128170098', 'runner.manage.present')
    res = new Resulter()
    res['return'] = ['minion1']
    res['fail'] = false
    data.results.set('master', res)
    defer.resolve data
    spyOn(Runner.prototype, 'commit').andReturn(defer.promise)
    $httpBackend.whenPOST('/run').respond({"return": [{"tag": "salt/run/20140408134128170098"}]})
    minions = null
    Salt.boot (salt) ->
      minions = salt.getMinions()
      return
    $httpBackend.flush()
    expect(minions.keys()).toEqual(['minion1'])

  it 'Deactivates minions that are not active', () ->
    m1 = new Minioner('minion1')
    m1.activize()
    m2 = new Minioner('minion2')
    m2.activize()
    AppData.getMinions().set('minion1', m1)
    AppData.getMinions().set('minion2', m2)
    defer = $q.defer()
    data = new Runner('20140408134128170098', 'runner.manage.present')
    res = new Resulter()
    res['return'] = ['minion2']
    res['fail'] = false
    data.results.set('master', res)
    defer.resolve data
    spyOn(Runner.prototype, 'commit').andReturn(defer.promise)
    $httpBackend.whenPOST('/run').respond({"return": [{"tag": "salt/run/20140408134128170098"}]})
    minions = null
    Salt.boot (salt) ->
      minions = (minion for minion in salt.getMinions().values() when minion.active)
    $httpBackend.flush()
    expect((minion.id for minion in minions)).toEqual(['minion2'])
