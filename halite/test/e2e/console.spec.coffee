describe 'Console Tab Tests', () ->

    beforeEach () ->
        browser().navigateTo('/app/console')
        input('login.username').enter(window.loginInfo.username)
        input('login.password').enter(window.loginInfo.password)
        element("#login-button").click()

    it 'should fetch docs from the server', () ->
        element("#fetch-docs").click()
        sleep(5)
        input('searchStr').enter('test.ping')
        browserTrigger(element('#doc-search'), 'change')
        value = element('pre')
        expect(value.html()).toContain('test.ping')

