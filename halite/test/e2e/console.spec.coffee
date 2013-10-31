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

    it 'should hide search results pre when the query is an empty string', () ->
        element("#fetch-docs").click()
        sleep(5)
        input('searchStr').enter('test.ping')
        browserTrigger(element('#doc-search'), 'change')
        input('searchStr').enter('')
        browserTrigger(element('#doc-search'), 'change')
        expect(element('pre:visible').count()).toBe(0)

