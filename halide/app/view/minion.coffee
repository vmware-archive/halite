mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'MinionCtlr', ['$scope', '$location', '$route','Configuration',
    'AppData', 'AppPref', 'OrderedData', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, AppData, AppPref, OrderedData, SaltApiSrvc) ->
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
        
        $scope.minions = new OrderedData()
        
        if !AppData.get('minions')?
            AppData.set('minions',{})
            
        $scope.reloadMinionFieldFromData = (field, data) ->
            minions = AppData.get('minions')
            if !minions
                minions = AppData.set('minions', {})
            
            #remove any minions from AppData that are not in data
            keys = (key for own key of minons)
            for key in keys
                if key not of data
                    delete minions[key]
            
            #update minions with new field values
            for key, val of data
                if !minions[key]?
                    minions[key] = {}
                minions[key][field] = val
            
            $scope.minions.reload(minions)
            
            console.log $scope.minions
            
        
        $scope.updateMinionFieldFromData = (field, data) ->
            minions = AppData.get('minions')
            if !minions
                minions = AppData.set('minions', {})
            
            #update minions with new field values
            for key, val of data
                if !minions[key]?
                    minions[key] = {}
                minions[key][field] = val
            
            $scope.minions.update(minions)
            
            console.log $scope.minions
            
        
        $scope.testPing = () ->
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
                    $scope.minions.update(data.return[0])
                    console.log $scope.minions
                return true
            return true
        
        $scope.filterMinions = (target) ->
            console.log "Filtering Minions with '#{target}'"
            
            return true
        
                
        return true
    ]