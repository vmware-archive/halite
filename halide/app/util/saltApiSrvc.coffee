###
usage:

mainApp = angular.module("MainApp", [... 'saltApiSrvc'])


mainApp.controller 'MyCtlr', ['$scope', ...,'SaltApiSrvc',
    ($scope,...,SaltApiSrvc) ->
    
    $scope.saltApiCallPromise = SaltApiSrvc.call $scope, [{'name':'John'}]
    $scope.saltApiCallPromise.success (data, status, headers, config) ->
        console.log("SaltApi call success")
        $scope.result = data
        return true
    
    $scope.saltApiLoginPromise = SaltApiSrvc.login $scope, 'usernamestring', 'passwordstring'
    $scope.saltApiLoginPromise.success (data, status, headers, config) ->
        console.log("SaltApi login success")
        $scope.result = data
        return true

###


saltApiSrvc = angular.module("saltApiSrvc", ['appConfigSrvc', 'appPrefSrvc', 'appStoreSrvc'])

saltApiSrvc.factory "SaltApiSrvc", ['$http', 'Configuration', 'AppPref', 'SessionStore', 
    ($http, Configuration, AppPref, SessionStore) -> 
        saltApi = AppPref.get('saltApi')
        if saltApi.scheme or saltApi.host or saltApi.port # absolute
            if not saltApi.scheme
                saltApi.scheme = "http"
            if not saltApi.host
                saltApi.host = "localhost"
            if saltApi.port
                saltApi.port = ":#{saltApi.port}"
            base = "#{saltApi.scheme}://#{saltApi.host}#{saltApi.port}#{saltApi.prefix}"
        else # relative
            base = "#{saltApi.prefix}"
            
        
        delete $http.defaults.headers.common['X-Requested-With'] # enable cors
        $http.defaults.useXDomain = true # enable cors on IE
        
        servicer = 
            call: ($scope, reqData) -> 
                headers = 
                    "X-Auth-Token": SessionStore.get('saltApiAuth')?.token
                    "Content-Type": "application/json"
                    "Accept": "application/json"
                    
                config =
                    headers: headers
                url = "#{base}/"
                $http.post( url, reqData, config  )
                .success((data, status, headers, config) ->
                    console.log "SaltApi call success"
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log "SaltApi call failure"
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data 
                    $scope.errorMsg = "Call Failed!"
                    return true
                )
            login: ($scope, username, password) -> 
                reqData = 
                    "username": username
                    "password": password
                    "eauth": "pam"
                    
                url = "#{base}/login"
                $http.post( url, reqData)
                .success((data, status, headers, config) ->
                    console.log "SaltApi login success" 
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log "SaltApi login failure" 
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data 
                    $scope.errorMsg = "Login Failed!"
                    return true
                )
            logout: ($scope) -> 
                headers = 
                    "X-Auth-Token": SessionStore.get('saltApiAuth')?.token
                config =
                    headers: headers
                url = "#{base}/logout"
                $http.post( url, {}, config)
                .success((data, status, headers, config) ->
                    console.log "SaltApi logout success" 
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log "SaltApi logout failure" 
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data 
                    $scope.errorMsg = "Logout Failed!"
                    return true
                )
            
        return servicer
        
    ] 