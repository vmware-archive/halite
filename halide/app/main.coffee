# To compile do
# $ coffee -c main.coffee 
# this creates main.js in same directory
# To automatically compile
# $ coffee -w -c main.coffee &


# angular.module() call registers demo for injection into other angular components
# assign to window.myApp if we want to have a global handle to the module

# Main App Module 
mainApp = angular.module("MainApp", ['configService', 'ssFilter', 'demoService'])


mainApp.constant 'MainConstants', 
    name: 'Halide'
    owner: 'SaltStack'

mainApp.config ["Configuration", "MainConstants","$locationProvider", "$routeProvider", 
    (Configuration, MainConstants, $locationProvider, $routeProvider) ->
        $locationProvider.html5Mode(true)
        console.log("Configuration")
        console.log(Configuration)
        console.log("MainConstants")
        console.log(MainConstants)
        #using absolute urls here in html5 mode
        base = Configuration.baseUrl # for use in coffeescript string interpolation #{base}
        
        $routeProvider
        .when "#{base}/app/home",
            templateUrl: "#{base}/static/app/view/home.html"
            controller: "HomeCtlr"
        .when "#{base}/app/watch/:id",
            templateUrl: "#{base}/static/app/view/watch.html"
            controller: "WatchCtlr"
        .when "#{base}/app/test",
            templateUrl: "#{base}/static/app/view/test.html"
            controller: "TestCtlr"
        .otherwise 
            redirectTo: "#{base}/app/home"

        return true
]

mainApp.controller 'NavbarCtlr', ['$scope', '$location', '$route', '$routeParams','Configuration',
    ($scope, $location, $route, $routeParams, Configuration) ->
        console.log("NavbarCtlr")
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        $scope.baseUrl = Configuration.baseUrl
        $scope.errorMsg = ''
        
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

        return true
]


mainApp.controller 'RouteCtlr', ['$scope', '$location', '$route', '$routeParams',
        'Configuration',
    ($scope, $location, $route, $$routeParams, Configuration) ->
        console.log("RouteCtlr")
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        $scope.baseUrl = Configuration.baseUrl
        $scope.errorMsg = ''

        return true
]
