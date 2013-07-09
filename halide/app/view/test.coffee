mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'TestCtlr', ['$scope', '$location', '$route','Configuration',
    'DemoService',
($scope, $location, $route, Configuration, DemoService) ->
    $scope.location = $location
    $scope.route = $route
    $scope.winLoc = window.location

    console.log("TestCtlr")
    $scope.errorMsg = ""

    $scope.demoPromise = DemoService.call $scope, 'doit', {'name':'John'}
    $scope.demoPromise.success (data, status, headers, config) ->
        console.log("Demo success")
        $scope.demo = data
        return true

    return true
]