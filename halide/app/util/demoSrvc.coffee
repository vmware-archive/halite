###
usage:
$scope.demoPromise = DemoService.call $scope, 'doit', {'name':'John'}
$scope.demoPromise.success (data, status, headers, config) ->
    console.log("Demo success")
    $scope.demo = data
    return true

###


angular.module("demoService", ['metaService']).factory "DemoService", 
    ['$http', 'MetaConstants', ($http, MetaConstants) -> 
        { #object literal
            call: ($scope, action, query) -> 
                base = MetaConstants.baseUrl
                url = if action? then "#{base}/demo/#{action}" else "#{base}/demo"
                $http.get( url, {params: query}  )
                .success((data, status, headers, config) ->
                    console.log("DemoService #{action} success")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log("DemoService #{action} failure")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    $scope.errorMsg=data?.error or data
                    return true
                )
        }
    ] 