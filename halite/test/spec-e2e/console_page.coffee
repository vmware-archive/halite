class ConsolePage

  navigate: (username, password) ->
    browser.get 'console'
    element(By.model('login.username')).sendKeys(username)
    element(By.model('login.password')).sendKeys(password)
    element(By.css('#login-button')).click()

  getManagePresentRow: () ->
    return element(By.repeater('job in jobs.values() | filter:jobPresentationFilter | orderBy:sortJobs:jobReverse | pagerize:jobPager').row(1))

  getJobButton: () ->
    return element(By.css('#job-button'))

  getManagePresentResult: () ->
    return @getManagePresentRow().findElements(By.css('n'))

  getManageJobResultButton: () ->
    return @getManagePresentRow().findElement(By.css('button'))

  toggleCommandPanelVisibility: () ->
    element(By.css('.monitorControls')).click()

  enterSearchQuery: (searchStr) ->
    element(By.model('command.cmd.fun')).sendKeys(searchStr)

  toggleSearchDocs: () ->
    element(By.model('docSearch')).click()    

module.exports = new ConsolePage
