mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'ConsoleCtlr', ['$scope', '$location', '$route', '$q',
    'Configuration','AppData', 'AppPref', 'Itemizer', 'Orderer', 
    'SaltApiSrvc', 'SaltApiEvtSrvc', 'SessionStore',
    ($scope, $location, $route, $q, Configuration, AppData, AppPref, Itemizer, 
    Orderer, SaltApiSrvc, SaltApiEvtSrvc, SessionStore) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        #console.log("ConsoleCtlr")
        $scope.errorMsg = ""
        $scope.closeAlert = () ->
            $scope.errorMsg = ""
        
        $scope.graining = false
        $scope.pinging = false
        $scope.statusing = false
        $scope.minioning = false
        $scope.commanding = false
        $scope.historing = false
        
        if !AppData.get('jobs')?
            AppData.set('jobs', new Itemizer())
        $scope.jobs = AppData.get('jobs')
        
        if !AppData.get('minions')?
            AppData.set('minions', new Itemizer())
        $scope.minions = AppData.get('minions')
        
        
        $scope.searchTarget = ""
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
            result = if result? then result else false
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
            cmd =
                mode: "async"
                fun: "runner.manage.status"

            $scope.statusing = true   
            SaltApiSrvc.run($scope, [cmd])
            .success (data, status, headers, config) ->
                $scope.statusing = false 
                result = data.return?[0]
                if result
                    console.log result
                    
                    #$scope.reloadMinions($scope.buildStatae(result), "status")
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
            cmd =
                mode: "async"
                fun: "test.ping"
                tgt: target
            
            $scope.pinging = true
            SaltApiSrvc.run($scope, [cmd])
            .success (data, status, headers, config) ->
                $scope.pinging = false
                result = data.return?[0]
                if result
                    job = $scope.startJob(result, cmd.fun)
                    job.get('promise').then (donejob) ->
                        $scope.buildPings(donejob)
                    
                    #$scope.updateMinions($scope.buildPings(result), "ping")
                return true
            .error (data, status, headers, config) ->
                $scope.pinging = false
                
            return true
        
        
        $scope.buildPings = (job) ->
            results = job.get('results')
            for key in $scope.minions.keys()
                ping = false
                if key in results.keys()
                    result = results.get(key)
                    if not result['fail']
                        ping = result['return']
                    
                $scope.minions.get(key).set('ping', ping)
            return true   
                    
            
        $scope.fetchGrains = (target) ->
            target = if target then target else "*"
            cmd =
                mode: "sync"
                fun: "grains.items"
                tgt: target
            
            $scope.graining = true
            SaltApiSrvc.run($scope, [cmd])
            .success (data, status, headers, config) ->
                $scope.graining = false
                result = data.return?[0]
                if result
                    console.log result
                    if angular.isString(result)
                        $scope.errorMsg = result
                        return false
                    
                    $scope.updateMinions(result, "grains")
                return true
            .error (data, status, headers, config) ->
                $scope.graining = false
            return true
        
        $scope.fetchMinions = () ->
            cmds =
            [
                mode: "sync"
                fun: "runner.manage.status"
            ,
                mode: "sync"
                fun: "grains.items"
                tgt: "*"
            ,
                mode: "sync"
                fun: "test.ping"
                tgt: "*"
            ]
            fields = ['status', 'grains', 'ping']
            
            $scope.minioning = true
            SaltApiSrvc.run($scope, cmds)
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
                $scope.commanding = false
                result = data.return[0]
                console.log result
                return true
            .error (data, status, headers, config) ->
                $scope.commanding = false

        $scope.reloadJobs = (data, field) ->
            ### update jobs and then remove via filter stale jobs not
                in data
            ###
            $scope.updateJobs(data, field)
            keys = ( key for key, val of data)
            $scope.jobs?.filter(keys)
            return true
        
        $scope.updateJobs = (data, field) ->
            ### 
            Update multiple jobs with entries in data where each entry is
            jid: stuff
            put stuff in field of job 
            
            primary job entry key is the jid
            ###
            for key, val of data
                if not $scope.jobs.get(key)?
                    $scope.jobs.set(key, new Itemizer())
                $scope.jobs.get(key).deepSet(field, val)
            $scope.jobs.sort(null, true)
            return true
        
        $scope.updateJobField = (jid, field, value) ->
            if not $scope.jobs.get(jid)?
                $scope.jobs.set(jid, new Itemizer())
            $scope.jobs.get(jid).deepSet(field, val)
            
        $scope.newJob = (job, mids) ->
            results = job.get('results')
            for mid in mids
                if not results.get(mid)?
                    results.set(mid, mid, 'id')
                $scope.initResult(results.get(mid))
            return job
            
        $scope.startJob = (result, fun) ->
            console.log "Start Job"
            console.log result
            jid = result.jid
            if not $scope.jobs.get(jid)?
                job = new Itemizer()
                $scope.initJob(job, jid, fun)
                $scope.jobs.set(jid, job)
            job = $scope.jobs.get(jid)
            $scope.newJob(job, result.minions)
            return job
        
        $scope.initJob = (job, jid, fun) ->
            job.set('jid', jid)
            job.set('fun', fun)
            job.set('events',[])
            job.set('results', new Itemizer())
            job.set('fail', true)
            job.set('errors', [])
            job.set('done', false)
            job.set('defer', $q.defer())
            job.set('promise', job.get('defer').promise)
            return job
             
        $scope.initResult = (result) ->
            ### minion result object in $scope.jobs job.results ###
            result['minion'] = null # minion link to itemizer $scope.minions
            result['done'] = false
            result['fail'] = true
            result['error'] = ''
            result['success'] = false
            result['return'] = null
            result['retcode'] = null
            return result
        
        $scope.initMinion = (minion, mid) ->
            ### itemizer in $scope.minions ###
            minion.set('id', mid)
            minion.set('jobs', new Itemizer())
            return minion
        
        $scope.linkJobMinion = (job, mid) ->
            if not $scope.minions.get(mid)?
                $scope.minions.set(mid, new Itemizer())
                $scope.initMinion($scope.minions.get(mid), mid)
            minion = $scope.minions.get(mid)
            minion.get('jobs').set(job.get('jid'), job)
            
            job.get('results').get(mid)['minion'] = minion
            return true
        
        $scope.checkJobDone = (job) ->
            results = job.get('results')
            fail = false
            for result in results.values()
                if not result['done']
                    return false
                if result['fail']
                    fail = true
             
            job.set('done', true)
            job.set('fail', fail)
            console.log "Job Done Fail = #{fail}"
            console.log job
            
            if job.get('errors').length > 0
                job.get('defer')?.reject(job.get('errors'))
            else
                job.get('defer')?.resolve(job)
            
            job.set('defer', null)
            job.set('promise', null)
            return true

        $scope.processJobNewEvent = (job, data) ->
            #console.log "Job New Event"
            $scope.newJob(job, data.minions)
            return job
        
        $scope.processJobRetEvent = (job, data) ->
            #console.log "Job Ret Event"
            results = job.get('results')
            if not results.get(data.id)?
                results.set(data.id, data.id, 'id')
                $scope.initResult(results.get(data.id))
            result = results.get(data.id)
            
            result['done']=true
            result['success'] = data.success
            if data.success == true
                result['retcode'] = data.retcode
            if data.success == true
                if data.retcode == 0
                    result['return'] = data.return
                    result['fail'] = false
                else
                    result['error'] = "Error retcode = #{data.retcode}"
                    job.get('errors').push(result['error'])
            else 
                result['error'] = data.return
                job.get('errors').push(result['error'])
            
            $scope.linkJobMinion(job, data.id)      
            $scope.checkJobDone(job)
            return job
        
            
        $scope.processRunNewEvent = (job, data) ->
            console.log "RunNewEvent"
            return job
        
        $scope.processRunRetEvent = (job, data) ->
            console.log "RunRetEvent"
            return job
        
        $scope.processJobEvent = (job, edata) ->
            events = job.get('events')
            events.push edata
            return job
            
        $scope.processSaltEvent = (edata) ->
            console.log "Process Salt Event: "
            console.log edata
            parts = _(edata.tag).words(".") # split on "." character
            if parts[0] is 'salt'
                if parts[1] is 'job' or parts[1] is 'run'
                    jid = parts[2]
                    if jid != edata.data.jid
                        console.log "Bad job event"
                        $scope.errorMsg = "Bad job event: JID #{jid} not match #{edata.jid}"
                        return false
                    if not $scope.jobs.get(jid)?
                        job = new Itemizer()
                        $scope.initJob(job, jid, edata.data.fun)
                        $scope.jobs.set(jid, job)
                    job = $scope.jobs.get(jid)
                    $scope.processJobEvent(job, edata)
                    kind = parts[3]
                    if kind == 'new'
                        $scope["process#{_(parts[1]).capitalize()}NewEvent"](job, edata.data)
                        #$scope.processJobNewEvent(job, edata)
                    else if kind == 'ret'
                        $scope["process#{_(parts[1]).capitalize()}RetEvent"](job, edata.data)
                        #$scope.processJobRetEvent(job, edata)
                    
            return edata
            
        $scope.openEventStream = () ->
            $scope.eventPromise = SaltApiEvtSrvc.events($scope, 
                $scope.processSaltEvent, "salt.")
            .then (data) ->
                console.log "Opened Event Stream: "
                console.log data
            , (data) ->
                console.log "Error Opening Event Stream"
                console.log data
                
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
            
        
        $scope.$on('ToggleAuth', $scope.authListener)
        
        #if not $scope.minions.keys().length and SessionStore.get('loggedIn') == true
        #   $scope.fetchMinions()
        
        return true
    ]
