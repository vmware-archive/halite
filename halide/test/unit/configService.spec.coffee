# jasmine

describe "ConfigService suite", () ->
  Configuration = null

  beforeEach module('configService')
  
  beforeEach inject (_Configuration_) ->
    Configuration = _Configuration_
  

  afterEach () ->
    return true


  it "give access to the Configuration", () ->
    expect(Configuration.baseUrl).toBeDefined();
    expect(Configuration.date).toBeDefined();
  
  it "baseUrl is /halide", () ->
    expect(Configuration.baseUrl).toEqual('/halide');