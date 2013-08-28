mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'ConsoleCtlr', ['$scope', '$location', '$route', '$q',
    'Configuration','AppData', 'AppPref', 'Item', 'Itemizer', 
    'Minioner', 'Resulter', 'Jobber', 'Runner',
    'SaltApiSrvc', 'SaltApiEvtSrvc', 'SessionStore',
    ($scope, $location, $route, $q, Configuration, AppData, AppPref, 
    Item, Itemizer, Minioner, Resulter, Jobber, Runner,
    SaltApiSrvc, SaltApiEvtSrvc, SessionStore) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        #console.log("ConsoleCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""
            
        $scope.monitorMode = "job"
        
        $scope.graining = false
        $scope.pinging = false
        $scope.statusing = false
        $scope.eventing = false
        $scope.commanding = false
        $scope.historing = false
        
        $scope.testJobber = () ->
            myjob = new Jobber()
            myrun = new Runner()
            mymin = new Minioner()
            
            return myjob
            
        
        if !AppData.get('jobs')?
            AppData.set('jobs', new Itemizer())
        $scope.jobs = AppData.get('jobs')
        
        if !AppData.get('minions')?
            AppData.set('minions', new Itemizer())
        $scope.minions = AppData.get('minions')
        
        $scope.searchTarget = ""
        
        $scope.filterage =
            grains: ["any", "id", "host", "domain", "server_id"]
            grain: "any"
            target: ""
            express: ""
        
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
                #$scope.filterage.express = $scope.filterage.target
                regex = RegExp($scope.filterage.target, "i")
                $scope.filterage.express = (minion) ->
                    for grain in minion.grains.values()
                        if angular.isString(grain) and grain.match(regex)
                            return true
                        
                    return false
            else
                regex = RegExp($scope.filterage.target,"i")
                name = $scope.filterage.grain
                $scope.filterage.express = (minion) ->
                    return minion.grains.get(name).toString().match(regex)
            return true

        $scope.sortage =
            targets: ["id", "grains", "ping", "active"]
            target: "id"
            reverse: false

        $scope.setSortTarget = (index) ->
            $scope.sortage.target = $scope.sortage.targets[index]
            return true
            
        $scope.sortMinions = (minion) ->
            if $scope.sortage.target is "id"
                result = minion.grains.get("id")
            else if $scope.sortage.target is "grains"
                result = minion.grains.get($scope.sortage.target)?
            else
                result = minion[$scope.sortage.target]
            result = if result? then result else false
            return result
        
        $scope.reverse = true
        $scope.sortJobs = (job) ->
            result = job.jid
            result = if result? then result else false
            return result
        
        
        $scope.actions =
            State:
                highstate:
                    mode: 'sync'
                    tgt: '*'
                    fun: 'state.highstate'
                show_highstate:
                    mode: 'sync'
                    tgt: '*'
                    fun: 'state.show_highstate'
                running:
                    mode: 'sync'
                    tgt: '*'
                    fun: 'state.running'
        
        $scope.runAction = (group, name) ->
            cmd = $scope.actions[group][name]
                
        $scope.command =
            result: {}
            history: {}
            lastCmd: null
            cmd:
                mode: 'async'
                fun: ''
                tgt: '*'
                args: ['']
            
            size: (obj) ->
                return _.size(obj)
            
            addArg: () ->
                @cmd.args.push('')
                
            delArg: () ->
                if @cmd.args.length > 1
                    @cmd.args = @cmd.args[0..-2]

            getCmd: () ->
                cmd =
                [
                    fun: @cmd.fun,
                    mode: @cmd.mode,
                    tgt: @cmd.tgt,

                    arg: (arg for arg in @cmd.args when arg isnt '')
                ]
                return cmd

        $scope.action = (cmd) ->
            $scope.commanding = true
            if not cmd
                cmd = $scope.command.getCmd()
                
            SaltApiSrvc.action($scope, cmd )
            .success (data, status, headers, config ) ->
                results = data.return
                for result, index in results
                    if result
                        parts = cmd[index].fun.split(".") # split on "." character
                        if parts.length == 3 
                            if parts[0] =='runner'
                                job = $scope.startRun(result, cmd[index].fun)
                            else if parts[0] == 'wheel'
                                console.log "Wheel"
                                console.log result
                        else
                            job = $scope.startJob(result, cmd[index].fun)
                    $scope.commanding = false
                return true
            .error (data, status, headers, config) ->
                $scope.commanding = false
                
        $scope.fetchPings = (target) ->
            target = if target then target else "*"
            cmd =
                mode: "async"
                fun: "test.ping"
                tgt: target
            
            $scope.pinging = true
            SaltApiSrvc.run($scope, [cmd])
            .success (data, status, headers, config) ->
                result = data.return?[0]
                if result
                    job = $scope.startJob(result, cmd.fun)
                $scope.pinging = false
                return true
            .error (data, status, headers, config) ->
                $scope.pinging = false
                
            return true
        
        $scope.fetchActives = () ->
            cmd =
                mode: "async"
                fun: "runner.manage.status"

            $scope.statusing = true   
            SaltApiSrvc.run($scope, [cmd])
            .success (data, status, headers, config) ->
                result = data.return?[0]
                if result
                    job = $scope.startRun(result, cmd.fun)
                    job.commit($q).then (donejob) ->
                        $scope.assignActives(donejob)
                        $scope.$emit("Marshall")
                return true
            .error (data, status, headers, config) ->
                $scope.statusing = false        
            return true
        
        $scope.assignActives = (job) ->
            for {key: mid, val: result} in job.results.items()
                unless result.fail
                    status = result.return
                    mids = []
                    for mid in status.up
                        minion = $scope.getMinion(mid)
                        minion.activize()
                        mids.push mid
                    for mid in status.down
                        minion = $scope.getMinion(mid)
                        minion.deactivize()
                        mids.push mid
                    for key in $scope.minions.keys()
                        unless key in mids
                            minion = $scope.getMinion(key)
                            minion.unlinkJobs()
                    $scope.minions?.filter(mids) #remove non status minions
            $scope.statusing = false
            return job
            
        $scope.fetchGrains = (target) ->
            target = if target then target else "*"
            cmd =
                mode: "async"
                fun: "grains.items"
                tgt: target
            
            $scope.graining = true
            SaltApiSrvc.run($scope, [cmd])
            .success (data, status, headers, config) ->
                result = data.return?[0]
                if result
                    job = $scope.startJob(result, cmd.fun)
                    job.commit($q).then (donejob) ->
                        $scope.assignGrains(donejob)
                    #$scope.graining = false
                return true
            .error (data, status, headers, config) ->
                $scope.graining = false
            return true
        
        $scope.assignGrains = (job) ->
            for {key: mid, val: result} in job.results.items()
                unless result.fail
                    grains = result.return
                    minion = $scope.getMinion(mid)
                    minion.grains.reload(grains, true)
            $scope.graining = false
            return job   

        $scope.getMinion = (mid) ->
            # Gets minion by minion Id mid or creates and inits if not exist
            if not $scope.minions.get(mid)?
                $scope.minions.set(mid, new Minioner(mid))
            return ($scope.minions.get(mid))

        $scope.startRun = (tag, fun) ->
            console.log "Start Run #{fun}"
            console.log tag
            parts = tag.split(".")
            jid = parts[2]
            if not $scope.jobs.get(jid)?
                job = new Runner(jid, fun)
                $scope.jobs.set(jid, job)
            job = $scope.jobs.get(jid)
            return job
                        
        $scope.startJob = (result, fun) ->
            console.log "Start Job #{fun}"
            console.log result
            jid = result.jid
            unless $scope.jobs.get(jid)?
                job = new Jobber(jid, fun)
                $scope.jobs.set(jid, job)
            job = $scope.jobs.get(jid)
            job.initResults(result.minions)
            return job
        
        $scope.resultKeys = ["done", "fail", "success", "retcode" ]
        
        $scope.processJobEvent = (jid, kind, edata) ->
            job = $scope.jobs.get(jid)
            job.processEvent(edata)
            data = edata.data
            if kind == 'new'
                job.processNewEvent(data)
            else if kind == 'ret'
                minion = $scope.getMinion(data.id)
                minion.activize() #since we got a return then minion must be active
                job.linkMinion(minion)
                job.processRetEvent(data)
                job.checkDone()
            return job
        
        $scope.processRunEvent = (jid, kind, edata) ->
            job = $scope.jobs.get(jid)
            job.processEvent(edata)
            data = edata.data
            if kind == 'new'
                job.processNewEvent(data)
            else if kind == 'ret'
                job.processRetEvent(data)
            return job
        
        $scope.processMinionEvent = (mid, edata) ->
            minion = $scope.getMinion(mid)
            minion.processEvent(edata)
            minion.activize()
            $scope.fetchGrains(mid)
            return minion
        
        $scope.processKeyEvent = (edata) ->
            data = edata.data
            mid = data.id
            minion = $scope.getMinion(mid)
            if data.result is true
                if data.act is 'delete'
                    minion.unlinkJobs()
                    $scope.minions.del(mid)
            return minion
            
        $scope.processSaltEvent = (edata) ->
            console.log "Process Salt Event: "
            console.log edata
            parts = edata.tag.split(".") # split on "." character
            if parts[0] is 'salt'
                if parts[1] is 'job'
                    jid = parts[2]
                    if jid != edata.data.jid
                        console.log "Bad job event"
                        $scope.errorMsg = "Bad job event: JID #{jid} not match #{edata.data.jid}"
                        return false
                    if not $scope.jobs.get(jid)?
                        job = new Jobber(jid, edata.data.fun)
                        $scope.jobs.set(jid, job)
                    kind = parts[3]
                    $scope.processJobEvent(jid, kind, edata)
                    
                else if parts[1] is 'run'
                    jid = parts[2]
                    if jid != edata.data.jid
                        console.log "Bad run event"
                        $scope.errorMsg = "Bad run event: JID #{jid} not match #{edata.data.jid}"
                        return false
                    if not $scope.jobs.get(jid)?
                        job = new Runner(jid, edata.data.fun)
                        $scope.jobs.set(jid, job)
                    kind = parts[3]
                    $scope.processRunEvent(jid, kind, edata)
                    
                else if parts[1] is 'minion' or parts[1] is 'syndic'
                    mid = parts[2]
                    if mid != edata.data.id
                        console.log "Bad minion event"
                        $scope.errorMsg = "Bad minion event: MID #{mid} not match #{edata.data.id}"
                        return false
                    $scope.processMinionEvent(mid, edata)
                
                 else if parts[1] is 'key'
                    $scope.processKeyEvent(edata)
                    
                    
            return edata
            
        $scope.openEventStream = () ->
            $scope.eventing = true
            $scope.eventPromise = SaltApiEvtSrvc.events($scope, 
                $scope.processSaltEvent, "salt.")
            .then (data) ->
                console.log "Opened Event Stream: "
                console.log data
                $scope.$emit('Activate')
                $scope.eventing = false
            , (data) ->
                console.log "Error Opening Event Stream"
                console.log data
                $scope.eventing = false
                return data
            return true
        
        $scope.closeEventStream = () ->
            console.log "Closing Event Stream"
            SaltApiEvtSrvc.close()
            return true
        
        $scope.authListener = (event, loggedIn) ->
            console.log "Received #{event.name}"
            console.log event
            if loggedIn
                $scope.openEventStream()
            else
                $scope.closeEventStream()
            
        $scope.activateListener = (event) ->
            console.log "Received #{event.name}"
            console.log event
            $scope.fetchActives()
        
        $scope.marshallListener = (event) ->
            console.log "Received #{event.name}"
            console.log event
            $scope.fetchGrains()
            
        $scope.$on('ToggleAuth', $scope.authListener)
        $scope.$on('Activate', $scope.activateListener)
        $scope.$on('Marshall', $scope.marshallListener)
        
        if not SaltApiEvtSrvc.active and SessionStore.get('loggedIn') == true
            $scope.openEventStream()
        
        return true
    ]
