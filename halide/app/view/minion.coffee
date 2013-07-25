mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'MinionCtlr', ['$scope', '$location', '$route','Configuration',
    'AppData', 'AppPref', 'OData', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, AppData, AppPref, OData, SaltApiSrvc) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("MinionCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""
        
        $scope.collapsedA = true
        
        $scope.searchTarget = ""
        $scope.filterTarget = ""
        

        if !AppData.get('minions')?
            AppData.set('minions',{})
        
        $scope.minions = new OData(AppData.get('minions'),true)
            
        $scope.reloadMinions = (data, field) ->
            keys = ( key for key, val of data)
            $scope.minions?.filter(keys)
            $scope.updateMinions(data, field)
            return true
            
        $scope.updateMinions = (data, field) ->
            for key, val of data
                if not $scope.minions.get(key)?
                    $scope.minions.set(key, new OData())
                $scope.minions.get(key).deepSet(field, val)
            $scope.minions.sort(null, true)
            AppData.set('minions', $scope.minions.unitemize())
            return true
        
        $scope.fetchPings = () ->
            console.log "Pinging Minions"
            lowState =
                fun: "test.ping"
                client: "local"
                tgt: "*"
                arg: ""
                
            $scope.saltApiCallPromise = SaltApiSrvc.act $scope, [lowState]
            $scope.saltApiCallPromise.success (data, status, headers, config) ->
                console.log("SaltApi Call success")
                console.log data
                if data.return?[0]
                    $scope.reloadMinions(data.return[0], "ping")
                    console.log $scope.minions
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
                
            $scope.saltApiCallPromise = SaltApiSrvc.act $scope, [lowState]
            $scope.saltApiCallPromise.success (data, status, headers, config) ->
                console.log("SaltApi Call success")
                console.log data
                if data.return?[0]
                    $scope.reloadMinions(data.return[0], "grains")
                    console.log $scope.minions
                return true
            return true
        
        $scope.filterMinions = (target) ->
            console.log "Filtering Minions with '#{target}'"
            return true
        
        return true
    ]