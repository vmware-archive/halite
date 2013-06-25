#usage
# $scope.actionPromise = TeamActionService.call($scope, tid, 'practice')
# sends post to "/owd/team/2/practice"

angular.module("demoService", []).factory "DemoService", 
    ['$http', ($http) -> 
        { #object literal
            call: ($scope, action) -> 
                $http.get( "/demo" )
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