mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','Configuration',
    'AppPref', 'OrderedData',
    ($scope, $location, $route, Configuration, AppPref, OrderedData) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("HomeCtlr")
        $scope.errorMsg = ""
        $scope.config = Configuration
        
        $scope.isArray = angular.isArray
        $scope.isObject = angular.isObject
        $scope.isNumber = angular.isNumber
        $scope.isBoolean = (obj) ->
            if obj? and
                Object.prototype.toString.call(obj) is "[object Boolean]"
                    return true
            return false
            
        $scope.fixNumber = (obj) ->
            if !obj
                return 0
            return obj
                
        $scope.updatePrefs = () ->
            prefs = $scope.prefs.unitemize()
            for own key, val of prefs
                AppPref.set(key, val)
            console.log AppPref.getAll()
            
        $scope.resetPrefs = () ->
            AppPref.clear()
            AppPref.reload()
            $scope.prefs = (new OrderedData()).deepUpdate AppPref.getAll()
            console.log AppPref.getAll()
        
        $scope.prefs = (new OrderedData()).deepUpdate AppPref.getAll()
        console.log $scope.prefs
        
                
        return true
    ]