mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'MinionCtlr', ['$scope', '$location', '$route','Configuration',
    'AppData', 'AppPref', 'Itemizer', 'Orderer', 'SaltApiSrvc', 'SaltApiEvtSrvc'
    ($scope, $location, $route, Configuration, AppData, AppPref, Itemizer, 
    Orderer, SaltApiSrvc, SaltApiEvtSrvc) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        #console.log("MinionCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""
        
        $scope.graining = false
        $scope.pinging = false
        $scope.statusing = false
        $scope.minioning = false
        $scope.commanding = false
        $scope.historing = false
        
        if !AppData.get('minions')?
            AppData.set('minions', new Itemizer())
        $scope.minions = AppData.get('minions')
        
        $scope.searchTarget = ""
        $scope.actions =
            State:
                highstate:
                    client: 'local'
                    tgt: '*'
                    fun: 'state.highstate'
                    arg: ['']
                show_highstate:
                    client: 'local'
                    tgt: '*'
                    fun: 'state.show_highstate'
                    arg: ['']
                running:
                    client: 'local'
                    tgt: '*'
                    fun: 'state.running'
                    arg: ['']
        
        $scope.runAction = (group, name) ->
            cmd = $scope.actions[group][name]
                
        
        $scope.filterage =
            grains: ["any", "id", "host", "domain", "server_id"]
            grain: "any"
            target: ""
            express: ""
        
        $scope.reverse = false
        $scope.sortage =
            targets: ["id", "grains", "ping", "status"]
            target: "id"
            reverse: false

        $scope.setFilterGrain = (index) ->
            $scope.filterage.grain = $scope.filterage.grains[index]
            $scope.setFilterExpress()
            return true
        
        $scope.setFilterTarget = (target) ->
            $scope.filterage.target = target
            $scope.setFilterExpress()
            return true
        
        $scope.setFilterExpress = () ->
            console.log "setFilterExpress"
            if $scope.filterage.grain is "any"
                $scope.filterage.express = $scope.filterage.target
            else
                regex = RegExp($scope.filterage.target,"i")
                grain = $scope.filterage.grain
                $scope.filterage.express = (minion) ->
                    return minion.val.get("grains").get(grain).toString().match(regex)
            return true
        
        $scope.setSortTarget = (index) ->
            $scope.sortage.target = $scope.sortage.targets[index]
            return true
            
        $scope.sortMinions = (minion) ->
            if $scope.sortage.target is "id"
                result = minion.val.get("grains")?.get("id")
            else if $scope.sortage.target is "grains"
                result = minion.val.get($scope.sortage.target)?
            else
                result = minion.val.get($scope.sortage.target)
            return result
        
        $scope.reloadMinions = (data, field) ->
            $scope.updateMinions(data, field)
            keys = ( key for key, val of data)
            $scope.minions?.filter(keys)
            return true
            
        $scope.updateMinions = (data, field) ->
            for key, val of data
                if not $scope.minions.get(key)?
                    $scope.minions.set(key, new Itemizer())
                $scope.minions.get(key).deepSet(field, val)
            $scope.minions.sort(null, true)
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
            
            $scope.graining = true
            SaltApiSrvc.act($scope, [lowState])
            .success (data, status, headers, config) ->
                $scope.graining = false
                result = data.return?[0]
                if result
                    #console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    
                    $scope.updateMinions(result, "grains")
                return true
            .error (data, status, headers, config) ->
                $scope.graining = false
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
        
        $scope.command =
            result: {}
            history: {}
            lastCmd: null
            lowstate:
                client: 'local'
                tgt: '*'
                fun: ''
                args: ['']
            
            size: (obj) ->
                return _.size(obj)
            
            addArg: () ->
                @lowstate.args.push('')
                
            delArg: () ->
                if @lowstate.args.length > 1
                    @lowstate.args = @lowstate.args[0..-2]

            getCmd: () ->
                cmd =
                [
                    client: @lowstate.client,
                    tgt: @lowstate.tgt,
                    fun: @lowstate.fun,
                    arg: (arg for arg in @lowstate.args when arg isnt '')
                ]
                return cmd
        


        $scope.action = (cmd) ->
            $scope.commanding = true
            if not cmd
                cmd = $scope.command.getCmd()
                
            SaltApiSrvc.action($scope, cmd )
            .success (data, status, headers, config ) ->
                $scope.commanding = false
                result = data.return[0]
                console.log result
                return true
            .error (data, status, headers, config) ->
                $scope.commanding = false

        
        $scope.testEventStream = () ->
            $scope.eventPromise = SaltApiEvtSrvc.events()
            .then (data) ->
                console.log("Resolved: " + data)
                return data
            return true
        
        
        if not $scope.minions.keys().length
            $scope.fetchMinions()
        
        return true
    ]