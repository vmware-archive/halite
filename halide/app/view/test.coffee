mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'TestCtlr', ['$scope', '$location', '$route','Configuration',
    'SaltApiSrvc', 'DemoSrvc',
($scope, $location, $route, Configuration, SaltApiSrvc, DemoSrvc) ->
    $scope.location = $location
    $scope.route = $route
    $scope.winLoc = window.location

    console.log("TestCtlr")
    $scope.errorMsg = ""
    
    
    $scope.demo = ""
    
    $scope.minions = {}
        
    $scope.testPing = () ->
        console.log "Test Ping"
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
        console.log "Fetch Minion Grains"
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
        
    $scope.testDemo = () ->    
        $scope.demoPromise = DemoSrvc.call $scope, 'doit', 'name': 'John'
        $scope.demoPromise.success (data, status, headers, config) ->
            console.log("Demo success")
            $scope.demo = data
            return true
    
    return true
]