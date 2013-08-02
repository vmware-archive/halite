###
usage:

mainApp = angular.module("MainApp", [... 'saltApiSrvc'])


mainApp.controller 'MyCtlr', ['$scope', ...,'SaltApiSrvc',
    ($scope,...,SaltApiSrvc) ->

    $scope.saltApiCallPromise = SaltApiSrvc.act $scope, [{'name':'John'}]
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


        # Remove noise header; not used by salt-api
        delete $http.defaults.headers.common['X-Requested-With']
        $http.defaults.useXDomain = true # enable cors on IE

        servicer =
            act: ($scope, reqData) ->
                headers =
                    "X-Auth-Token": SessionStore.get('saltApiAuth')?.token

                config =
                    headers: headers
                url = "#{base}/"
                $http.post( url, reqData, config  )
                .success((data, status, headers, config) ->
                    return true
                )
                .error((data, status, headers, config) ->
                    $scope.errorMsg = "Call Failed!"
                    return true
                )
            login: ($scope, username, password) ->
                reqData =
                    "username": username
                    "password": password
                    "eauth": saltApi.eauth

                url = "#{base}/login"
                $http.post( url, reqData)
                .success((data, status, headers, config) ->
                    return true
                )
                .error((data, status, headers, config) ->
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
                    return true
                )
                .error((data, status, headers, config) ->
                    $scope.errorMsg = "Logout Failed!"
                    return true
                )

        return servicer

    ]
