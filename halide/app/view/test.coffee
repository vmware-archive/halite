mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'TestCtlr', ['$scope', '$location', '$route','MetaConstants',
     'DemoService',
    ($scope, $location, $route, MetaConstants, DemoService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("TestCtlr")
        $scope.errorMsg = ""
        
        return true
]