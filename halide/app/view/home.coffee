mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','Configuration',
    'AppPref',
    ($scope, $location, $route, Configuration, AppPref) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("HomeCtlr")
        $scope.errorMsg = ""
        
        $scope.prefs = AppPref.getAll()
        
        $scope.updatePrefs = () ->
            for own key, val of $scope.prefs
                AppPref.set(key, val)
            $scope.prefs = AppPref.getAll()
        
                
        return true
    ]