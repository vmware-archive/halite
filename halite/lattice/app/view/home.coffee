mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','Configuration',
    'AppPref', 'Itemizer', 
    ($scope, $location, $route, Configuration, AppPref, Itemizer) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        #console.log("HomeCtlr")
        $scope.errorMsg = ""
        $scope.config = Configuration
        
        $scope.isArray = angular.isArray
        $scope.isObject = (obj) ->
            return (angular.isObject(obj) and not angular.isArray(obj))
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
            #console.log AppPref.getAll()
            
        $scope.resetPrefs = () ->
            AppPref.clear()
            AppPref.reload()
            #$scope.prefs = new Itemizer(AppPref.getAll(), true)
            $scope.prefs.reload(AppPref.getAll(), true)
            #console.log AppPref.getAll()
        
        $scope.prefs = new Itemizer(AppPref.getAll(), true)
        #console.log $scope.prefs
        
        
        
        return true
    ]