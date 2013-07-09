mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','Configuration',
     'DemoService',
    ($scope, $location, $route, Configuration, DemoService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("HomeCtlr")
        $scope.errorMsg = ""
        
        $scope.views = Configuration.views
        return true
]