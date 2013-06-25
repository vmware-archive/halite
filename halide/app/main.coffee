# To compile do
# $ coffee -c main.coffee 
# this creates main.js in same directory
# To automatically compile
# $ coffee -w -c main.coffee &


# angular.module() call registers demo for injection into other angular components
# assign to window.myApp if we want to have a global handle to the module

# Main App Module 
mainApp = angular.module("MainApp", ['metaService', 'demoService'])


mainApp.constant 'MainConstants', 
    name: 'Halide'
    owner: 'SaltStack'

mainApp.config ["MetaConstants", "MainConstants","$locationProvider", "$routeProvider",
    (MetaConstants, MainConstants, $locationProvider, $routeProvider) ->
        $locationProvider.html5Mode(true)
        console.log("MetaConstants")
        console.log(MetaConstants)
        console.log("MainConstants")
        console.log(MainConstants)
        #using absolute urls here in html5 mode
        base = MetaConstants.baseUrl # for use in coffeescript string interpolation #{base}
        $routeProvider.when "#{base}/app/home",
            templateUrl: "#{base}/static/app/view/home.html"
            controller: "HomeCtlr"
        .otherwise redirectTo: "#{base}/app/home"
        return true
]

