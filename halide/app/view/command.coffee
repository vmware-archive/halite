mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'CommandCtlr', ['$scope', '$location', '$route','Configuration',
    ($scope, $location, $route, Configuration) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("CommandCtlr")
        $scope.errorMsg = ""

        return true
]
