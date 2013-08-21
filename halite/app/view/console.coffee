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
        $scope.eventing = false
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
                        parts = _(cmd[index].fun).words(".") # split on "." character
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
                
        $scope.filterage =
            grains: ["any", "id", "host", "domain", "server_id"]
            grain: "any"
            target: ""
            express: ""
        
        $scope.reverse = false
        $scope.sortage =
            targets: ["id", "grains", "ping", "active"]
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
                    job.get('promise').then (donejob) ->
                        $scope.buildActives(donejob)
                        $scope.$emit("Marshall")
                
                return true
            .error (data, status, headers, config) ->
                $scope.statusing = false        
            return true
        
        $scope.buildActives = (job) ->
            result = job.get('return')
            mids = []
            for mid in result.up
                $scope.activize(mid)
                mids.push mid
            for mid in result.down
                $scope.deactivize(mid)
                mids.push mid
            
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
                    job.get('promise').then (donejob) ->
                        $scope.buildGrains(donejob)
                return true
            .error (data, status, headers, config) ->
                $scope.graining = false
            return true
        
        $scope.buildGrains = (job) ->
            results = job.get('results')
            for mid in results.keys()
                result = results.get(mid)
                if not result['fail']
                    grains = result['return']
                    $scope.deepSetMinionField(mid, 'grains', grains)
            $scope.graining = false
            return job   

        $scope.setMinionField = (mid, field, value) ->
            $scope.getMinion(mid).set(field, value)
            return true
            
        $scope.deepSetMinionField = (mid, field, value) ->
            $scope.getMinion(mid).deepSet(field, value)
            return true
        
        $scope.updateMinionField = (mid, field, value) ->
            $scope.getMinion(mid).deepSet(field, value, true)
            return true
        
        $scope.activize = (mid) ->
            $scope.deepSetMinionField(mid, 'active', true)
            return true
        
        $scope.deactivize = (mid) ->
            $scope.deepSetMinionField(mid, 'active', false)
            return true
        
        $scope.processMinionEvent = (minion, edata) ->
            minion.get('events').set(edata.tag, edata)
            return minion
        
        $scope.initMinion = (minion, mid) ->
            ### itemizer in $scope.minions ###
            minion.set('id', mid)
            minion.set('jobs', new Itemizer())
            minion.set('active', false)
            minion.set('events', new Itemizer())
            return minion
        
        $scope.getMinion = (mid) ->
            # Gets minion by minion Id mid or creates and inits if not exist
            if not $scope.minions.get(mid)?
                $scope.minions.set(mid, new Itemizer())
                $scope.initMinion($scope.minions.get(mid), mid)
            return ($scope.minions.get(mid))

        $scope.updateJobField = (jid, field, value) ->
            if not $scope.jobs.get(jid)?
                $scope.jobs.set(jid, new Itemizer())
            $scope.jobs.get(jid).deepSet(field, val, true)

        $scope.startRun = (tag, fun) ->
            console.log "Start Run #{fun}"
            console.log tag
            parts = _(tag).words(".")
            jid = parts[2]
            if not $scope.jobs.get(jid)?
                job = new Itemizer()
                $scope.initJob(job, jid, fun)
                $scope.jobs.set(jid, job)
            job = $scope.jobs.get(jid)
            $scope.newRun(job)
            return job
        
        $scope.newRun = (job) ->
            job.set('success', false)
            job.set('return', null)
            return job
            
        $scope.processRunNewEvent = (job, data) ->
            console.log "RunNewEvent"
            $scope.newRun(job)
            return job
        
        $scope.processRunRetEvent = (job, data) ->
            console.log "RunRetEvent"
            
            job.set('done', true)
            job.set('success', data.success)
            job.set('fail', not data.success)
            if data.success == true
                job.set('return', data.ret)
            else
                job.get('errors').push(data.ret)
                
            console.log "Job Done Fail = #{job.get('fail')}"
            console.log job
            
            if job.get('errors').length > 0
                job.get('defer')?.reject(job.get('errors'))
            else
                job.get('defer')?.resolve(job)
            
            job.set('defer', null)
            job.set('promise', null)
            return job
                        
        $scope.startJob = (result, fun) ->
            console.log "Start Job #{fun}"
            console.log result
            jid = result.jid
            if not $scope.jobs.get(jid)?
                job = new Itemizer()
                $scope.initJob(job, jid, fun)
                $scope.jobs.set(jid, job)
            job = $scope.jobs.get(jid)
            $scope.newJob(job, result.minions)
            return job
        
        $scope.newJob = (job, mids) ->
            if not job.get('results')?
                job.set('results', new Itemizer())
            results = job.get('results')
            for mid in mids
                if not results.get(mid)?
                    results.set(mid, {})
                $scope.initResult(results.get(mid), mid)
            return job
        
        $scope.initJob = (job, jid, fun) ->
            job.set('jid', jid)
            job.set('fun', fun)
            job.set('events', new Itemizer())
            job.set('fail', true)
            job.set('errors', [])
            job.set('done', false)
            job.set('defer', $q.defer())
            job.set('promise', job.get('defer').promise)
            return job
             
        $scope.initResult = (result, mid) ->
            ### minion result object in $scope.jobs job.results ###
            result['id'] = mid
            result['minion'] = null # minion link to itemizer $scope.minions
            result['active'] = $scope.minions.get(mid)?.get('active')
            result['done'] = false
            result['fail'] = true
            result['error'] = ''
            result['success'] = false
            result['return'] = null
            result['retcode'] = null
            return result
        
        $scope.linkJobMinion = (job, mid) ->
            minion = $scope.getMinion(mid)
            minion.get('jobs').set(job.get('jid'), job)
            
            job.get('results').get(mid)['minion'] = minion
            return true
        
        $scope.checkJobDone = (job) ->
            results = job.get('results')
            # active is true or null ie not false
            done = _((result.done for result in results.values() when\
                result.active isnt false)).all()
            if not done
                return false
            
            job.set('done', done)
            
            fail = _((result.fail for result in results.values() when\
                result.active and result.done )).any()
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
            mid = data.id
            if not results.get(mid)?
                results.set(mid, mid, 'id')
                $scope.initResult(results.get(mid))
            result = results.get(mid)
            
            result['done'] = true
            result['active'] = true
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
            
            $scope.linkJobMinion(job, mid) 
            $scope.activize(mid) #since we got a return then minion must be active
            $scope.checkJobDone(job)
            return job
        
        $scope.processJobEvent = (job, edata) ->
            job.get('events').set(edata.tag, edata)
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
                        $scope.errorMsg = "Bad job event: JID #{jid} not match #{edata.data.jid}"
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
                    else if kind == 'ret'
                        $scope["process#{_(parts[1]).capitalize()}RetEvent"](job, edata.data)
                else if parts[1] is 'minion' or parts[1] is 'syndic'
                    mid = parts[2]
                    if mid != edata.data.id
                        console.log "Bad minion event"
                        $scope.errorMsg = "Bad minion event: MID #{mid} not match #{edata.data.id}"
                        return false
                    minion = $scope.getMinion(mid)
                    $scope.processMinionEvent(minion, edata)
                    $scope.activize(mid)
                    $scope.fetchGrains(mid)
                    
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
