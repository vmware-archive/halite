mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'MinionCtlr', ['$scope', '$location', '$route','Configuration',
    'AppData', 'AppPref', 'Itemizer', 'Orderer', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, AppData, AppPref, Itemizer, 
    Orderer, SaltApiSrvc) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        #console.log("MinionCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""
        
        $scope.minioning = false
        $scope.statusing = false
        $scope.pinging = false
        $scope.refreshing = false
        $scope.searchTarget = ""
        $scope.filterTarget = ""
        $scope.filterPattern = 
            $: ""
        $scope.sortTarget = "id"
        $scope.reverse = false

        if !AppData.get('minions')?
            #AppData.set('minions',{})
            AppData.set('minions', new Itemizer())
        
        #$scope.minions = new Itemizer(AppData.get('minions'),true)
        $scope.minions = AppData.get('minions')
            
        $scope.reloadMinions = (data, field) ->
            keys = ( key for key, val of data)
            $scope.minions?.filter(keys)
            $scope.updateMinions(data, field)
            return true
            
        $scope.updateMinions = (data, field) ->
            for key, val of data
                if not $scope.minions.get(key)?
                    $scope.minions.set(key, new Itemizer())
                $scope.minions.get(key).deepSet(field, val)
            $scope.minions.sort(null, true)
            #AppData.set('minions', $scope.minions.unitemize())
            
            return true
        
        
        $scope.fetchStatae = () ->
            lowState =
                fun: "manage.status"
                client: "runner"
                tgt: ""
                arg: ""
            
            $scope.statusing = true   
            SaltApiSrvc.act($scope, [lowState])
            .success (data, status, headers, config) ->
                $scope.statusing = false 
                result = data.return?[0]
                if result
                    #console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    $scope.reloadMinions($scope.buildStatae(result), "status")
                return true
            .error (data, status, headers, config) ->
                $scope.statusing = false        
            return true
        
        $scope.buildStatae = (result) ->
            statae = {}
            for name in result.up
                statae[name]=true
            for name in result.down
                statae[name]=false
            return statae
        
        $scope.fetchPings = (target) ->
            target = if target then target else "*"
            lowState =
                fun: "test.ping"
                client: "local"
                tgt: target
                arg: ""
            
            $scope.pinging = true
            SaltApiSrvc.act($scope, [lowState])
            .success (data, status, headers, config) ->
                $scope.pinging = false
                result = data.return?[0]
                if result
                    #console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    $scope.updateMinions($scope.buildPings(result), "ping")
                return true
            .error (data, status, headers, config) ->
                $scope.pinging = false
                
            return true
        
        $scope.buildPings = (result) ->
            for key in $scope.minions.keys()
                if key not of result
                    result[key] = false
            return result
            
        $scope.fetchGrains = (target) ->
            target = if target then target else "*"
            lowState =
                fun: "grains.items"
                client: "local"
                tgt: target
                arg: ""
            
            $scope.refreshing = true
            SaltApiSrvc.act($scope, [lowState])
            .success (data, status, headers, config) ->
                $scope.refreshing = false
                result = data.return?[0]
                if result
                    #console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    
                    $scope.updateMinions(result, "grains")
                return true
            .error (data, status, headers, config) ->
                $scope.refreshing = false
            return true
        
        $scope.fetchMinions = () ->
            lowStates =
            [
                fun: "manage.status"
                client: "runner"
                tgt: ""
                arg: ""
            ,
                fun: "grains.items"
                client: "local"
                tgt: "*"
                arg: ""
            ,
                fun: "test.ping"
                client: "local"
                tgt: "*"
                arg: ""
            ]
            fields = ['status', 'grains', 'ping']
            #console.log lowStates
            
            $scope.minioning = true
            SaltApiSrvc.act($scope, lowStates)
            .success (data, status, headers, config) ->
                $scope.minioning = false
                results = data.return
                for result, i in results
                    #console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    if fields[i] is "status"
                        result = $scope.buildStatae(result)
                        $scope.reloadMinions(result, fields[i])
                    else
                        if fields[i] is "ping"
                            result = $scope.buildPings(result)
                        $scope.updateMinions(result, fields[i])
                return true
            .error (data, status, headers, config) ->
                $scope.minioning = false
            return true
        
        $scope.filterMinions = (target) ->
            $scope.filterPattern.$ = target
            return true
        
        $scope.sortMinions = (minion) ->
            return minion?.val?.get("grains")?.val?.get("id")
        
        if not $scope.minions.keys().length
            $scope.fetchMinions()
        
        return true
    ]