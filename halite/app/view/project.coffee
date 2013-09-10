mainApp = angular.module("MainApp")

mainApp.controller 'ProjectCtlr', [
    '$scope', '$location', '$route','Configuration', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, SaltApiSrvc) ->
        $scope.errorMsg = ""
        

        return true
]
