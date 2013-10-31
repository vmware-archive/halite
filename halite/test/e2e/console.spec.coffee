describe 'Console Tab Tests', () ->

    beforeEach () ->
        browser().navigateTo('/app/console')
        input('login.username').enter(window.loginInfo.username)
        input('login.password').enter(window.loginInfo.password)
        element("#login-button").click()
        sleep(5) # so that the sys.doc function ajax call has a chance to return

    it 'should search docs when checkbox is checked', () ->
        input('docSearch').check()
        input('command.cmd.fun').enter('test.ping')
        browserTrigger(element('#idModuleFunction'), 'change')
        value = element('pre')
        expect(value.html()).toContain('test.ping')

    it 'should not search docs when checkbox is unchecked', () ->
        # checkbox is unchecked by default
        input('command.cmd.fun').enter('test.ping')
        browserTrigger(element('#idModuleFunction'), 'change')
        value = element('pre')
        expect(value.html()).toContain('')
        expect(element('pre:visible').count()).toBe(0)

    it 'should hide search results pre when the query is an empty string', () ->
        input('docSearch').check()
        input('command.cmd.fun').enter('test.ping')
        browserTrigger(element('#idModuleFunction'), 'change')
        input('command.cmd.fun').enter('')
        browserTrigger(element('#idModuleFunction'), 'change')
        expect(element('pre:visible').count()).toBe(0)

    it 'should not show pre when checkbox is checked initially with no text in the textbox', () ->
        input('docSearch').check()
        value = element('pre')
        expect(value.html()).toContain('test.ping')
        expect(element('pre:visible').count()).toBe(0)
