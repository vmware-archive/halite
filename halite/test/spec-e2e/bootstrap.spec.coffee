describe "Halite Bootstrap Tests", () ->

  consolePage = require('./console_page.coffee')

  beforeEach () ->
    consolePage.navigate()

  it "Performs manage.present", () ->
    consolePage.getJobButton().click().then () ->
      result = consolePage.getManagePresentRow()
      consolePage.getManageJobResultButton().click().then () ->
        row = consolePage.getManagePresentRow()
        elem = row.findElement(By.css('n'))
        elem.getInnerHtml().then (results) ->
          expect(results).toBeDefined()
