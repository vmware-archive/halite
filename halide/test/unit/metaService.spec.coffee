# jasmine

describe "MetaService suite", () ->
  MetaConstants = null

  beforeEach module('metaService')
  
  beforeEach inject (_MetaConstants_) ->
    MetaConstants = _MetaConstants_
  

  afterEach () ->
    return true


  it "give access to the MetaConstants", () ->
    expect(MetaConstants.baseUrl).toBeDefined();
    expect(MetaConstants.date).toBeDefined();
  
  it "baseUrl is /halide", () ->
    expect(MetaConstants.baseUrl).toEqual('/halide');