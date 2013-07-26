# jasmine

describe "Basic app disply suite", () ->
  foo = null

  beforeEach () ->
    browser().navigateTo('/halite/app/home')

  afterEach () ->
    browser().navigateTo('/halite/app/home')
    browser().reload()


  it "check home view window path", () ->
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halite/app/home')
  
  it "check test view window path", () ->
    browser().navigateTo('/halite/app/test')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halite/app/test')
    
  it "check app view window path", () ->
    browser().navigateTo('/halite/app')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halite/app')
  
  it "check navbar click", () ->
    browser().navigateTo('/halite/app/home')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halite/app/home')
    expect(element('li:contains("Test")').count()).toBe(1)
    expect(element('a:contains("Test")').count()).toBe(1)
    element('a:contains("Test")').click();
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halite/app/test')