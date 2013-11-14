describe "App Data Service Tests", () ->

  AppData = null

  beforeEach module "appDataSrvc"

  beforeEach inject (_AppData_) ->
    AppData = _AppData_

  it "sets the value for a given key", () ->
    AppData.set('foo', 'bar')
    expect(AppData.get('foo')).toBe('bar')

  it "deletes key properly", () ->
    AppData.set('foo', 'bar')
    AppData.del('foo')
    expect(AppData.get('foo')).toBeUndefined()

  it 'gets all keys', () ->
    AppData.set('foo', 'bar')
    AppData.set('spam', 'eggs')
    expect(AppData.keys()).toContain('foo')
    expect(AppData.keys()).toContain('spam')

  it 'clears keys', () ->
    AppData.set('foo', 'bar')
    AppData.set('spam', 'eggs')
    val = (key for own key of AppData.clear())
    val = val.join()
    expect(val).toBe('')
