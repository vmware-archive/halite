mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','MainConstants',
     'DemoService',
    ($scope, $location, $route, MainConstants, DemoService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.windowLocation = window.location
        
        console.log("HomeCtlr")
        $scope.errorMsg = ""
        $scope.baseUrl = MainConstants.baseUrl
        return true
]