# jasmine

describe "Basic app disply suite", () ->
  foo = null

  beforeEach () ->
    browser().navigateTo('/halide/app/home')

  afterEach () ->
    browser().navigateTo('/halide/app/home')
    browser().reload()


  it "check home view window path", () ->
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halide/app/home')
  
  it "check test view window path", () ->
    browser().navigateTo('/halide/app/test')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halide/app/test')
    
  it "check app view window path", () ->
    browser().navigateTo('/halide/app')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halide/app')
  
  it "check navbar click", () ->
    browser().navigateTo('/halide/app/home')
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halide/app/home')
    expect(element('li:contains("Test")').count()).toBe(1)
    expect(element('a:contains("Test")').count()).toBe(1)
    element('a:contains("Test")').click();
    expect(browser().window().path()).toBeDefined()
    expect(browser().window().path()).toContain('halide/app/test')