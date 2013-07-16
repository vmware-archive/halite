###
Application State Data Service
Provides shared global application state data
usage:

mainApp = angular.module("MainApp", [... 'appDataSrvc'])


mainApp.controller 'MyCtlr', ['$scope', ...,'AppData',
    ($scope,...,AppData) ->
    
    $scope.appData = AppData.getData()
    AppData.setData
        loggedIn: true
    

###


angular.module("appDataSrvc", ['appConfigSrvc']).factory "AppData", 
    ['Configuration', (Configuration) -> 
        appData = {}
            
        base = Configuration.baseUrl
        
        servicer =
            getData: () ->
                return appData
            
            setData: (data) ->
                for own key, val of data
                    appData[key] = val
                return appData
            
        return servicer
    ] 