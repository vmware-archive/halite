mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','Configuration',
    'AppPref',
    ($scope, $location, $route, Configuration, AppPref) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("HomeCtlr")
        $scope.errorMsg = ""
        
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
                
        #ng-repeat on forms messes up iterating on object need list
        # recursivley convert objects to lists
        $scope.listify = (prefs) ->  
            prefsList = []
            for own key, val of prefs
                if angular.isObject(val)
                    prefsList.push 
                        key: key
                        val: $scope.listify(val)
                else
                    prefsList.push 
                        key: key
                        val: val
            return prefsList
        
        $scope.delistify = (prefsList) ->  
            prefs = {}
            for item in prefsList
                if angular.isArray(item.val)
                    prefs[item.key] = $scope.delistify(item.val)
                else
                    prefs[item.key] = item.val
            return prefs
            
        $scope.updatePrefs = () ->
            prefs = $scope.delistify($scope.prefs)
            for own key, val of prefs
                AppPref.set(key, val)
            console.log AppPref.getAll()
            
        $scope.resetPrefs = () ->
            AppPref.clear()
            AppPref.reload()
            $scope.prefs = $scope.listify AppPref.getAll()
            console.log AppPref.getAll()
        
        $scope.config = Configuration
        
        $scope.prefs = $scope.listify AppPref.getAll()
        console.log $scope.prefs
        
                
        return true
    ]