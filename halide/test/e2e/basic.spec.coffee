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
    
  