###
usage:

mainApp = angular.module("MainApp", [... 'saltApiSrvc'])


mainApp.controller 'MyCtlr', ['$scope', ...,'SaltApiSrvc',
    ($scope,...,SaltApiSrvc) ->
    
    $scope.saltApiCallPromise = SaltApiSrvc.call $scope, 'doit', {'name':'John'}
    $scope.saltApiCallPromise.success (data, status, headers, config) ->
        console.log("SaltApi success")
        $scope.result = data
        return true
    
    $scope.saltApiLoginPromise = SaltApiSrvc.login $scope, 'usernamestring', 'passwordstring'
    $scope.saltApiLoginPromise.success (data, status, headers, config) ->
        console.log("SaltApi success")
        $scope.result = data
        return true

###


angular.module("saltApiSrvc", ['configSrvc']).factory "SaltApiSrvc", 
    ['$http', 'Configuration', ($http, Configuration) -> 
        base = Configuration.baseUrl
        
        servicer = 
            call: ($scope, action, query) -> 
                url = if action? then "#{base}/demo/#{action}" else "#{base}/demo"
                $http.get( url, {params: query}  )
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
                    $scope.errorMsg = data?.error or data
                    return true
                )
            login: ($scope, username, password) -> 
                base = Configuration.baseUrl
                data = 
                    "username": "saltwui"
                    "password": "dissolve"
                    "eauth": "pam"
                    
                url = "https://localhost:8100/login"
                $http.post( url, {data: data}  )
                .success((data, status, headers, config) ->
                    console.log "SaltApi login success" 
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log("SaltApi login failure")
                    console.log config
                    console.log status
                    console.log headers()
                    console.log data 
                    $scope.errorMsg = data?.error or data
                    return true
                )
        return servicer
        
    ] 