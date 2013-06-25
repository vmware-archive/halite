#usage
# $scope.actionPromise = TeamActionService.call($scope, tid, 'practice')
# sends post to "/owd/team/2/practice"

angular.module("demoService", ['metaService']).factory "DemoService", 
    ['$http', 'MetaConstants', ($http, MetaConstants) -> 
        { #object literal
            call: ($scope, action) -> 
                base = MetaConstants.baseUrl
                $http.get( "#{base}/demo" )
                .success((data, status, headers, config) ->
                    console.log("DemoService #{action} success")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log("DemoService failure")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    $scope.errorMsg=data?.error or data
                    return true
                )
        }
    ] 