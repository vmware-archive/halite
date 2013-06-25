mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','MetaConstants',
     'DemoService',
    ($scope, $location, $route, MetaConstants, DemoService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.windowLocation = window.location
        
        console.log("HomeCtlr")
        $scope.errorMsg = ""
        $scope.baseUrl = MetaConstants.baseUrl
        return true
]