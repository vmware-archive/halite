describe "Basic Home Page Tests", () ->

  it "loads home page", () ->
    browser.get 'console/'
    ptor = protractor.getInstance()
    ptor.getCurrentUrl().then (url) ->
      expect(url).toBe(ptor.baseUrl + 'console')
