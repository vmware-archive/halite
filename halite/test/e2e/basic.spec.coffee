# jasmine

describe "Basic app disply suite", () ->
  foo = null

  beforeEach () ->
    browser().navigateTo('/app/home')

  afterEach () ->
    browser().navigateTo('/app/home')
    browser().reload()


  it "check home view window path", () ->
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('/app/home')
  
  it "check console view window path", () ->
    browser().navigateTo('/app/console')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('/app/console')
    
  it "check app view window path", () ->
    browser().navigateTo('/app')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('/app')
  
  it "check navbar click", () ->
    browser().navigateTo('/app/home')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('/app/home')
    expect(element('li:contains("Console")').count()).toBe(1)
    expect(element('a:contains("Console")').count()).toBe(1)
    element('a:contains("Console")').click();
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('/app/console')