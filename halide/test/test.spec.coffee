# jasmine
describe "A suite", () ->
    it "contains spec with an expectation", () -> 
        expect(true).toBe(true);


describe "A spec", () ->
  foo = 0

  beforeEach () ->
    foo = 0;
    foo += 1;


  afterEach () ->
    foo = 0;

  it "is just a function, so it can contain any code", () ->
    expect(foo).toEqual(1);


  it "can have more than one expectation", () ->
    expect(foo).toEqual(1);
    expect(true).toEqual(true);
  

  describe "nested inside a second describe", () ->
    bar = 0

    beforeEach () ->
      bar = 1;

    it "can reference both scopes as needed ", () ->
      expect(foo).toEqual(bar);
