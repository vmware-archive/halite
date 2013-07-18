###
Application Preferences Service
Uses LocalStore Service which uses html5 localStorage to persitently store
    on client browser computer the preferences
    

mainApp = angular.module("MainApp", [... 'appPrefSrvc'])


mainApp.controller 'MyCtlr', ['$scope', ...,'AppPref',
    ($scope,...,AppPrefs) ->
    
    $scope.appPrefs = AppPref.getAll()
    $scope.saltApi = AppPref.get('saltApi')
    
    AppPref.set
        saltApi: 
            scheme: "http"
            host: "localhost"
            port: "8100"
            prefix: ""
    

###


angular.module("appPrefSrvc", ['appConfigSrvc', 'appStoreSrvc']).factory "AppPref", 
    ['Configuration', 'LocalStore', (Configuration, LocalStore) -> 
        
        servicer =
            getAll: () ->
                prefs = LocalStore.get('Preferences')
                return if prefs then prefs else {}
                
            get: (key) ->
                prefs = this.getAll()
                return prefs?[key]
            
            set: (key, val) ->
                prefs = this.getAll()
                prefs[key] = val
                LocalStore.set('Preferences', prefs)
                return prefs
        
        
        # initialize preferences from configuration
        prefs = servicer.getAll()
        if not prefs?.saltApi?
            servicer.set('saltApi', Configuration.saltApi)
        if not prefs?.debug?
            servicer.set('debug', Configuration.debug)
        
            
        return servicer
    ] 