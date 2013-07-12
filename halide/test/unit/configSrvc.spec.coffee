# jasmine

describe "ConfigSrvc suite", () ->
  Configuration = null

  beforeEach module('configSrvc')
  
  beforeEach inject (_Configuration_) ->
    Configuration = _Configuration_
  

  afterEach () ->
    return true


  it "give access to the Configuration", () ->
    expect(Configuration.baseUrl).toBeDefined();
    expect(Configuration.date).toBeDefined();
  
  it "baseUrl is /halide", () ->
    expect(Configuration.baseUrl).toEqual('/halide');