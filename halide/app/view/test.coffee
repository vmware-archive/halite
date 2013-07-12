mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'TestCtlr', ['$scope', '$location', '$route','Configuration',
    'DemoSrvc',
($scope, $location, $route, Configuration, DemoSrvc) ->
    $scope.location = $location
    $scope.route = $route
    $scope.winLoc = window.location

    console.log("TestCtlr")
    $scope.errorMsg = ""

    $scope.demoPromise = DemoSrvc.call $scope, 'doit', {'name':'John'}
    $scope.demoPromise.success (data, status, headers, config) ->
        console.log("Demo success")
        $scope.demo = data
        return true
    
    return true
]