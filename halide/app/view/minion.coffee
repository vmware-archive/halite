mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'MinionCtlr', ['$scope', '$location', '$route','Configuration',
    'AppData', 'AppPref', 'Itemizer', 'Orderer', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, AppData, AppPref, Itemizer, 
    Orderer, SaltApiSrvc) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        console.log("MinionCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""
        
        $scope.searchTarget = ""
        $scope.filterTarget = ""
        $scope.filterPattern = 
            $: ""
        $scope.sortTarget = "id"
        $scope.reverse = false

        if !AppData.get('minions')?
            AppData.set('minions',{})
        
        $scope.minions = new Orderer(AppData.get('minions'),true)
            
        $scope.reloadMinions = (data, field) ->
            keys = ( key for key, val of data)
            $scope.minions?.filter(keys)
            $scope.updateMinions(data, field)
            return true
            
        $scope.updateMinions = (data, field) ->
            for key, val of data
                if not $scope.minions.get(key)?
                    $scope.minions.set(key, new Orderer())
                $scope.minions.get(key).deepSet(field, val)
            $scope.minions.sort(null, true)
            AppData.set('minions', $scope.minions.unorder())
            
            return true
        
        
        $scope.fetchStatae = () ->
            lowState =
                fun: "manage.status"
                client: "runner"
                tgt: ""
                arg: ""
                
            SaltApiSrvc.act($scope, [lowState])
            .success (data, status, headers, config) ->
                result = data.return?[0]
                if result
                    console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    statae = {}
                    for name in result.up
                        statae[name]=true
                    for name in result.down
                        statae[name]=false
                    $scope.reloadMinions(statae, "status")
                return true
                    
            return true
        
        
        $scope.fetchPings = () ->
            lowState =
                fun: "test.ping"
                client: "local"
                tgt: "*"
                arg: ""
                
            $scope.saltApiCallPromise = SaltApiSrvc.act $scope, [lowState]
            $scope.saltApiCallPromise.success (data, status, headers, config) ->
                result = data.return?[0]
                if result
                    console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    $scope.updateMinions(result, "ping")
                return true
            return true
            
        $scope.fetchMinions = (target) ->
            target = if target then target else "*"
            lowState =
                fun: "grains.items"
                client: "local"
                tgt: target
                arg: ""
                
            $scope.saltApiCallPromise = SaltApiSrvc.act $scope, [lowState]
            $scope.saltApiCallPromise.success (data, status, headers, config) ->
                console.log("SaltApi Call success")
                result = data.return?[0]
                if result
                    console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    
                    $scope.updateMinions(result, "grains")
                return true
            return true
        
        $scope.filterMinions = (target) ->
            $scope.filterPattern.$ = target
            return true
        
        $scope.sortMinions = (minion) ->
            return minion?.get("grains")?.get("id")
        
            
        $scope.fetchMinions()
        
        return true
    ]