mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'HomeCtlr', ['$scope', '$location', '$route','Configuration',
    'AppPref',
    ($scope, $location, $route, Configuration, AppPref) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("HomeCtlr")
        $scope.errorMsg = ""
        
        
        
        #ng-repeat on forms messes up iterating on object need list
        # recursivley convert objects to lists
        $scope.listify = (prefs) ->  
            prefsList = []
            for own key, val of prefs
                if angular.isObject(val)
                    prefsList.push {key: key val: $scope.listify(val)}
                else
                    prefsList.push {key: key, val: val}
            return prefsList
        
        $scope.delistify = (prefsList) ->  
            prefs = {}
            for item in prefsList
                if angular.isObject(item.val)
                    prefs[key] = $scope.delistify(item.val)
                else
                    prefs[key] = item.val
            return prefs
            
        $scope.updatePrefs = () ->
            prefs = $scope.delistify($scope.prefs)
            for own key, val of prefs
                AppPref.set(key, val)
            console.log AppPref.getAll()
        
        $scope.prefIsObject = (pref) ->
            return angular.isObject(pref)
        
        #$scope.prefs = $scope.listify(AppPref.getAll())
        
        
                
        return true
    ]