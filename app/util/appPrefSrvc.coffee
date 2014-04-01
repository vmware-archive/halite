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
                prefs = LocalStore.get('preferences')
                return if prefs then prefs else {}
            
            setAll: (prefs) ->
                LocalStore.set('preferences', prefs)
                return prefs
                
            get: (key) ->
                prefs = @getAll()
                return prefs?[key]
            
            set: (key, val) ->
                prefs = @getAll()
                prefs[key] = val
                @setAll(prefs)
                return prefs
            
            load: (prefs, config) ->
                for key, val of config
                    if not prefs?[key]?
                        prefs[key] = val
                    else if angular.isObject(val)
                        @load(prefs[key],val)
                @setAll(prefs)
                return prefs
            
            reload: () ->
                @load(@getAll(), Configuration.preferences)
                return @getAll()
            
            clear: () ->
                LocalStore.set('preferences', {})
        
        
        
        # initialize preferences from configuration
        servicer.reload()
        
            
        return servicer
    ] 