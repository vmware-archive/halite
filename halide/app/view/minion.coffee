mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'MinionCtlr', ['$scope', '$location', '$route','Configuration',
    'AppPref', 'OrderedData', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, AppPref, OrderedData, SaltApiSrvc) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("MinionCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""
        
        
        $scope.searchTarget = ""
        $scope.filterTarget = ""
        $scope.minions = new OrderedData()
        
        $scope.testPing = () ->
            console.log "Pinging Minions"
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
            
        $scope.fetchMinions = (target) ->
            target = if target then target else "*"
            console.log "Fetching Minions with '#{target}'"
            lowState =
                fun: "grains.items"
                client: "local"
                tgt: target
                arg: ""
                
            $scope.saltApiCallPromise = SaltApiSrvc.call $scope, [lowState]
            $scope.saltApiCallPromise.success (data, status, headers, config) ->
                console.log("SaltApi Call success")
                console.log data
                if data.return?[0]
                    $scope.minions.update(data.return[0])
                    console.log $scope.minions
                return true
            return true
        
        $scope.filterMinions = (target) ->
            console.log "Filtering Minions with '#{target}'"
            
            return true
        
                
        return true
    ]