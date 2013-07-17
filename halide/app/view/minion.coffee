mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'MinionCtlr', ['$scope', '$location', '$route','Configuration',
    'SaltApiSrvc',
    ($scope, $location, $route, Configuration, SaltApiSrvc) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("MinionCtlr")
        $scope.errorMsg = ""
        
        $scope.minions = {}
        
        $scope.testPing = () ->
            lowState =
                fun: "test.ping"
                client: "local"
                tgt: "*"
                arg: ""
                
            $scope.saltApiCallPromise = SaltApiSrvc.call $scope, [lowState]
            $scope.saltApiCallPromise.success (data, status, headers, config) ->
                console.log("SaltApi Call success")
                console.log data
                return true
            return true
            
        $scope.fetchMinionGrains = (target) ->
            lowState =
                fun: "grains.items"
                client: "local"
                tgt: if target then target else "*"
                arg: ""
                
            $scope.saltApiCallPromise = SaltApiSrvc.call $scope, [lowState]
            $scope.saltApiCallPromise.success (data, status, headers, config) ->
                console.log("SaltApi Call success")
                console.log data
                if data.return?[0]
                    $scope.minions = data.return[0]
                return true
            return true
        
        
                
        return true
    ]