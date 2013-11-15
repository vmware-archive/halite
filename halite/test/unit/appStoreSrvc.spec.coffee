describe "App Store Service Unit Tests", () ->

  LocalStore = null
  SessionStore = null

  beforeEach module "appStoreSrvc"

  beforeEach inject (_LocalStore_, _SessionStore_) ->
    LocalStore = _LocalStore_
    SessionStore = _SessionStore_

  describe 'LocalSorage Tests', () ->
    it 'stores the key', () ->
      LocalStore.set 'foo', 'bar'
      expect(LocalStore.get('foo')).toBe('bar')

    it 'clears keys', () ->
      LocalStore.set 'foo', 'bar'
      LocalStore.clear()
      expect(LocalStore.len()).toBe(0)

    it 'removes key', () ->
      LocalStore.set 'foo', 'bar'
      LocalStore.remove('foo')
      expect(LocalStore.get('foo')).toBeNull()

    it 'reports the correct len when keys are added', () ->
      LocalStore.set 'foo', 'bar'
      LocalStore.set 'foo2', 'bar2'
      expect(LocalStore.len()).toBe(2)

    it 'reports the correct len when keys are added and removed', () ->
      LocalStore.set 'foo', 'bar'
      LocalStore.set 'foo2', 'bar2'
      LocalStore.remove('foo')
      expect(LocalStore.len()).toBe(1)

  describe 'SessionSorage Tests', () ->
    it 'stores the key', () ->
      SessionStore.set 'foo', 'bar'
      expect(SessionStore.get('foo')).toBe('bar')

    it 'clears keys', () ->
      SessionStore.set 'foo', 'bar'
      SessionStore.clear()
      expect(SessionStore.len()).toBe(0)

    it 'removes key', () ->
      SessionStore.set 'foo', 'bar'
      SessionStore.remove('foo')
      expect(SessionStore.get('foo')).toBeNull()

    it 'reports the correct len when keys are added', () ->
      SessionStore.set 'foo', 'bar'
      SessionStore.set 'foo2', 'bar2'
      expect(SessionStore.len()).toBe(2)

    it 'reports the correct len when keys are added and removed', () ->
      SessionStore.set 'foo', 'bar'
      SessionStore.set 'foo2', 'bar2'
      SessionStore.remove('foo')
      expect(SessionStore.len()).toBe(1)
