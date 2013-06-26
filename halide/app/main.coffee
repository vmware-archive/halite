# To compile do
# $ coffee -c main.coffee 
# this creates main.js in same directory
# To automatically compile
# $ coffee -w -c main.coffee &


# angular.module() call registers demo for injection into other angular components
# assign to window.myApp if we want to have a global handle to the module

# Main App Module 
mainApp = angular.module("MainApp", ['metaService', 'demoService', 'ui.state'])


mainApp.constant 'MainConstants', 
    name: 'Halide'
    owner: 'SaltStack'

mainApp.config ["MetaConstants", "MainConstants","$locationProvider", "$routeProvider", 
        "$stateProvider", "$urlRouterProvider",
    (MetaConstants, MainConstants, $locationProvider, $routeProvider, 
        $stateProvider, $urlRouterProvider) ->
        $locationProvider.html5Mode(true)
        console.log("MetaConstants")
        console.log(MetaConstants)
        console.log("MainConstants")
        console.log(MainConstants)
        #using absolute urls here in html5 mode
        base = MetaConstants.baseUrl # for use in coffeescript string interpolation #{base}
        
        
        
        $stateProvider
        .state 'home', 
            url: "#{base}/app/home",
            templateUrl: "#{base}/static/app/view/home.html"
            controller: "HomeCtlr"
        .state 'test', 
            url: "#{base}/app/test",
            templateUrl: "#{base}/static/app/view/test.html"
            controller: "TestCtlr"
        
        $urlRouterProvider
        .otherwise "#{base}/app/home"
        
        return true
]

mainApp.controller 'NavbarCtlr', ['$scope', '$routeParams', '$location', '$route', 'MetaConstants',
    ($scope, $routeParams, $location, $route, MetaConstants) ->
        console.log("NavbarCtlr")
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        $scope.baseUrl = MetaConstants.baseUrl
        $scope.errorMsg = ''
        
        $scope.navery =
            'states': 
                'home' : 'inactive'
                'test' : 'inactive'
            
            'paths':
                "/app$": "home"
                "/app/home": "home"
                "/app/test": "test"
            
            'activate': (nav) ->
                @states[nav] = 'active'
                for x of this.states
                    if x != nav
                        @states[x] = 'inactive'
                return true
            
            'update': (newPath, oldPath) ->
                for path, nav of this.paths
                    if newPath.match(path)?
                        @activate(nav)
                        return true
                return true
        
        $scope.$watch('location.path()', (newPath, oldPath) ->
            $scope.navery.update(newPath, oldPath)
            return true
        )

        return true
]
