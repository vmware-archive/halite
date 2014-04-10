# To compile do
# $ coffee -c main.coffee
# this creates main.js in same directory
# To automatically compile
# $ coffee -w -c main.coffee &


# angular.module() call registers demo for injection into other angular components
# assign to window.myApp if we want to have a global handle to the module

# Main App Module
mainApp = angular.module("MainApp", ['ngRoute', 'ngCookies', 'ngAnimate',
        'appConfigSrvc', 'appPrefSrvc',
        'appDataSrvc', 'appStoreSrvc', 'appUtilSrvc', 'appFltr', 'appDrtv',
        'saltApiSrvc', 'demoSrvc', 'errorReportingSrvc', 'highstateCheckSrvc', 'eventSrvc', 'jobSrvc', 'saltSrvc',
        'fetchActivesSrvc'])


mainApp.constant 'MainConstants',
    name: 'Halite'
    owner: 'SaltStack'

mainApp.config ["Configuration", "MainConstants", "$locationProvider",
    "$routeProvider", "$httpProvider",
    (Configuration, MainConstants, $locationProvider, $routeProvider, $httpProvider) ->
        $locationProvider.html5Mode(true)
        #console.log("Configuration")
        #console.log(Configuration)
        #console.log("MainConstants")
        #console.log(MainConstants)
        #using absolute urls here in html5 mode
        base = Configuration.baseUrl # for use in coffeescript string interpolation #{base}

        #$httpProvider.defaults.useXDomain = true;
        #delete $httpProvider.defaults.headers.common['X-Requested-With']

        for name, item of Configuration.views
            if item.label? # item is a view
                $routeProvider.when item.route,
                    templateUrl: item.template
                    controller: item.controller
            else # item is a list of views
                for view in item
                    $routeProvider.when view.route,
                        templateUrl: view.template
                        controller: view.controller

        $routeProvider.otherwise
            redirectTo: Configuration.views.otherwise.route

        return true
]

mainApp.controller 'NavbarCtlr', ['$scope', '$rootScope', '$location', '$route',
    '$routeParams', 'Configuration', 'AppPref', 'AppData',
    'LocalStore', 'SessionStore', 'SaltApiSrvc',
    ($scope, $rootScope, $location, $route, $routeParams, Configuration, AppPref,
            AppData, LocalStore, SessionStore, SaltApiSrvc) ->
        #console.log("NavbarCtlr")
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        $scope.baseUrl = Configuration.baseUrl
        $scope.debug = AppPref.get('debug')
        $scope.errorMsg = ''

        $scope.isCollapsed = true;
        $scope.loggedIn = if SessionStore.get('loggedIn')? then SessionStore.get('loggedIn') else false
        $scope.username = SessionStore.get('saltApiAuth')?.user

        $scope.views = Configuration.views

        $scope.navery =
            'navs': {}

            'activate': (navact) ->
                navact.state = 'active'
                for label, nav of @navs
                    if nav != navact
                        nav.state = 'inactive'
                return true

            'update': (newPath, oldPath) ->
                for label, nav of @navs
                    if newPath.match(nav.matcher)?
                        @activate(nav)
                        return true
                return true

            'load': (views) ->
                for name, item of views
                    if item.label? #item is vies
                        @navs[item.label] =
                            state: 'inactive'
                            matcher: item.matcher

                    else # item is list of views
                        for view in item
                            @navs[view.label] =
                                state: 'inactive'
                                matcher: view.matcher

        $scope.navery.load($scope.views)

        $scope.$watch('location.path()', (newPath, oldPath) ->
            $scope.navery.update(newPath, oldPath)
            return true
        )

        $scope.login =
            username: ""
            password: ""


        $scope.logoutUser = () ->
            $scope.errorMsg = ""
            $scope.username = null
            $scope.loggedIn = false
            $scope.login =
                username: ""
                password: ""

            $scope.saltApiLogoutPromise = SaltApiSrvc.logout $scope
            $scope.saltApiLogoutPromise.success (data, status, headers, config) ->
                #console.log("SaltApi Logout success")
                #console.log data
                if data?.return?[0]?
                    SessionStore.set('loggedIn',$scope.loggedIn)
                    SessionStore.remove('saltApiAuth')
                    $rootScope.$broadcast('ToggleAuth', $scope.loggedIn)

                    #console.log SessionStore.get('loggedIn')
                    #console.log SessionStore.get('saltApiAuth')
                return true

            return true

        $scope.loginUser = () ->
            $scope.errorMsg = ""
            #console.log "Logging in as #{$scope.login.username} with #{$scope.login.password}"
            $scope.saltApiLoginPromise = SaltApiSrvc.login $scope, $scope.login.username, $scope.login.password
            $scope.saltApiLoginPromise.success (data, status, headers, config) ->
                #console.log("SaltApi Login success")
                #console.log data
                if data?.return?[0]?
                    auth = data.return[0]
                    saltApiAuth =
                        user: auth.user
                        token: auth.token
                        eauth: auth.eauth
                        start: auth.start
                        expire: auth.expire
                        perms: auth.perms[0]

                    $scope.loggedIn = true
                    SessionStore.set('loggedIn', $scope.loggedIn)
                    $scope.username = saltApiAuth.user
                    SessionStore.set('saltApiAuth', saltApiAuth )

                    $rootScope.$broadcast('ToggleAuth', $scope.loggedIn)

                    #console.log SessionStore.get('loggedIn')
                    #console.log SessionStore.get('saltApiAuth')
                return true

            return true

        $scope.loginFormError = () ->
            msg = ""
            if $scope.loginForm.$dirty and $scope.loginForm.$invalid
                requiredFields = ["username", "password"]

                erroredFields =
                    for name in requiredFields when $scope.loginForm[name].$error.required
                        $scope.loginForm[name].$name.substring(0,1).toUpperCase() + $scope.loginForm[name].$name.substring(1)

                if erroredFields
                    msg = erroredFields.join(" & ") + " missing!"

            return msg

        return true
]


mainApp.controller 'RouteCtlr', ['$scope', '$location', '$route', '$routeParams',
        'Configuration', 'AppPref',
    ($scope, $location, $route, $$routeParams, Configuration, AppPref) ->
        #console.log "RouteCtlr"
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        $scope.baseUrl = Configuration.baseUrl
        $scope.debug = AppPref.get('debug')
        $scope.errorMsg = ''


        return true
]
