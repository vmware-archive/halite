describe "Halite Bootstrap Tests", () ->

  consolePage = require('./console_page.coffee')
  credentials = require('./credentials.coffee')

  beforeEach () ->
    consolePage.navigate(credentials.username, credentials.password)

  it "Has the first element as manage.present", () ->
    consolePage.getJobButton().click().then () ->
      result = consolePage.getManagePresentRow()
      consolePage.getManageJobResultButton().click().then () ->
        row = consolePage.getManagePresentRow()
        row.findElement(By.css('.job-name')).getText().then (commandName) ->
          expect(commandName).toBe('runner.manage.present')
        elem = row.findElement(By.css('n'))
        elem.getInnerHtml().then (results) ->
          expect(results).toBeDefined()
