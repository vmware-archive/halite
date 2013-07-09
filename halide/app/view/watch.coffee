mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'WatchCtlr', ['$scope', '$location', '$route','Configuration',
     'DemoService',
    ($scope, $location, $route, Configuration, DemoService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("WatchCtlr")
        $scope.errorMsg = ""
        
        return true
]