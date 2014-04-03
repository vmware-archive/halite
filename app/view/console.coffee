mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'ConsoleCtlr', ['$scope', '$location', '$route', '$q', '$filter',
    '$templateCache',
    'Configuration','AppData', 'AppPref', 'Item', 'Itemizer',
    'Minioner', 'Resulter', 'Jobber', 'ArgInfo', 'Runner', 'Wheeler', 'Commander', 'Pagerage',
    'SaltApiSrvc', 'SaltApiEvtSrvc', 'SessionStore', 'ErrorReporter', 'JobDelegate', '$filter',
    ($scope, $location, $route, $q, $filter, $templateCache, Configuration,
    AppData, AppPref, Item, Itemizer, Minioner, Resulter, Jobber, ArgInfo, Runner, Wheeler,
    Commander, Pagerage, SaltApiSrvc, SaltApiEvtSrvc, SessionStore, ErrorReporter, JobDelegate ) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location

        #console.log("ConsoleCtlr")

        $scope.monitorMode = null

        $scope.graining = false
        $scope.pinging = false
        $scope.statusing = false
        $scope.eventing = false
        $scope.commanding = false
        $scope.docSearch = false

        $scope.newPagerage = (itemCount) ->
            return (new Pagerage(itemCount))

        $scope.grainsSortBy = ["id"]
        $scope.grainsSortBy = ["any", "id", "host", "domain", "server_id"] if AppPref.get('fetchGrains', false)
        $scope.grainsFilterBy = "id"
        $scope.grainsFilterBy = "any" if AppPref.get('fetchGrains', false)
        $scope.filterage =
            grains: $scope.grainsSortBy
            grain: $scope.grainsFilterBy
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
            # console.log "setFilterExpress"
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
                    if AppPref.get('fetchGrains', false)
                        return minion.grains.get(name).toString().match(regex)
                    else
                        return minion.id.match(regex)
            return true

        $scope.eventReverse = true
        $scope.jobReverse = true
        $scope.commandReverse = false
        $scope.minionSortageTargets = ["id"]
        $scope.minionSortageTargets = ["id", "grains", "ping", "active"] if AppPref.get('fetchGrains', false)
        $scope.sortage =
            targets: $scope.minionSortageTargets
            target: "id"
            reverse: false

        $scope.setSortTarget = (index) ->
            $scope.sortage.target = $scope.sortage.targets[index]
            return true

        $scope.sortMinions = (minion) ->
            if $scope.sortage.target is "id"
                if AppPref.get('fetchGrains', false)
                    result = minion.grains.get("id")
                else
                    result = minion.id
            else if $scope.sortage.target is "grains"
                result = minion.grains.get($scope.sortage.target)?
            else
                result = minion[$scope.sortage.target]
            result = if result? then result else false
            return result

        $scope.sortJobs = (job) ->
            result = job.jid
            result = if result? then result else false
            return result

        $scope.sortEvents = (event) ->
            result = event.utag
            result = if result? then result else false
            return result

        $scope.sortCommands = (command) ->
            result = command.name
            result = if result? then result else false
            return result

        $scope.resultKeys = ["retcode", "fail", "success", "done"]

        $scope.expandMode = (ensual) ->
            if angular.isArray(ensual)
                for x in ensual
                    if angular.isObject(x)
                        return 'list'
                return 'vect'
            else if angular.isObject(ensual)
                return 'dict'
            return 'lone'

        $scope.ensuals = (ensual) ->
            #makes and array so we can create new scope with ng-repeat
            #work around to recursive scope expression for ng-include
            return ([ensual])

        $scope.actions =
            State:
                highstate:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.highstate'
                show_highstate:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.show_highstate'
                show_lowstate:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.running'
                running:
                    mode: 'async'
                    tgt: '*'
                    fun: 'state.running'
            Test:
                ping:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.ping'
                echo:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.echo'
                    arg: ['Hello World']
                conf_test:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.conf_test'
                fib:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.fib'
                    arg: [8]
                collatz:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.collatz'
                    arg: [8]
                sleep:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.sleep'
                    arg: ['5']
                rand_sleep:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.rand_sleep'
                    arg: ['max=10']
                get_opts:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.get_opts'
                providers:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.providers'
                version:
                    mode: 'async'
                    tgt: '*'
                    fun: 'test.version'
                versions_information:
                    mode: 'async'
                    tgt: '*'

        $scope.ply = (cmds) ->
            target = if $scope.command.cmd.tgt isnt "" then $scope.command.cmd.tgt else "*"
            unless angular.isArray(cmds)
                cmds = [cmds]
            for cmd in cmds
                cmd.tgt = target
            $scope.action(cmds)

        $scope.command =
            result: {}
            history: {}
            lastCmds: null
            parameters: null
            cmd:
                mode: 'async'
                fun: ''
                tgt: '*'
                arg: [""]
                expr_form: 'glob'

            size: (obj) ->
                return _.size(obj)

            addArg: () ->
                @cmd.arg.push('')
                @parameters?.push('Enter Input')
                #@cmd.arg[_.size(@cmd.arg)] = ""

            delArg: () ->
                if @cmd.arg.length > 1
                    @cmd.arg = @cmd.arg[0..-2]

                if @parameters?.length > 0
                    @parameters.pop()
                #if _.size(@cmd.arg) > 1
                 #   delete @cmd.arg[_.size(@cmd.arg) - 1]

            getArgs: () ->
                #return (val for own key, val of @cmd.arg when val isnt '')
                return (arg for arg in @cmd.arg when arg isnt '')

            getCmds: () ->
                if @cmd.fun.split(".").length == 3 # runner or wheel not minion job
                    cmds =
                    [
                        fun: @cmd.fun,
                        mode: @cmd.mode,
                        arg: @getArgs()
                    ]
                else
                    cmds =
                    [
                        fun: @cmd.fun,
                        mode: @cmd.mode,
                        tgt: if @cmd.tgt isnt "" then @cmd.tgt else "",
                        arg: @getArgs(),
                        expr_form: @cmd.expr_form
                    ]

                return cmds

            humanize: (cmds) ->
                unless cmds
                    cmds = @getCmds()
                return (((part for part in [cmd.fun, cmd.tgt].concat(cmd.arg) \
                    when part? and part isnt '').join(' ') for cmd in cmds).join(',').trim())

        $scope.command.cmd.tgt = ""

        $scope.expressionFormats =
            Glob: 'glob'
            'Perl Regex': 'pcre'
            List: 'list'
            Grain: 'grain'
            'Grain Perl Regex': 'grain_pcre'
            Pillar: 'pillar'
            'Node Group': 'nodegroup'
            Range: 'range'
            Compound: 'compound'

        $scope.$watch "command.cmd.expr_form", (newVal, oldVal, scope) ->
            if newVal == oldVal
                return
            if newVal == 'glob'
                $scope.command.cmd.tgt = "*"
            else
                $scope.command.cmd.tgt = ""

        $scope.fixTarget = () ->
            if $scope.command.cmd.tgt? and $scope.command.cmd.expr_form == 'list' #remove spaces after commas
                $scope.command.cmd.tgt = $scope.command.cmd.tgt.replace(/,\s+/g,',')

        $scope.humanize = (cmds) ->
            unless angular.isArray(cmds)
                cmds = [cmds]
            return (((part for part in [cmd.fun, cmd.tgt].concat(cmd.arg) \
                    when part? and part isnt '').join(' ') for cmd in cmds).join(',').trim())

        $scope.action = (cmds) ->
            $scope.commanding = true
            if not cmds
                cmds = $scope.command.getCmds()
            command = $scope.snagCommand($scope.humanize(cmds), cmds)

            #console.log('Calling SaltApiSrvc.action')
            SaltApiSrvc.action($scope, cmds )
            .success (data, status, headers, config ) ->
                results = data.return
                for result, index in results
                    if not _.isEmpty(result)
                        parts = cmds[index].fun.split(".") # split on "." character
                        if parts.length == 3
                            if parts[0] =='runner'
                                job = JobDelegate.startRun(result, cmds[index]) #runner result is tag
                                command.jobs.set(job.jid, job)
                            else if parts[0] == 'wheel'
                                job = JobDelegate.startWheel(result, cmds[index]) #runner result is tag
                                command.jobs.set(job.jid, job)
                        else
                            job = JobDelegate.startJob(result, cmds[index])
                            command.jobs.set(job.jid, job)
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
                    job = JobDelegate.startJob(result, cmd)
                $scope.pinging = false
                return true
            .error (data, status, headers, config) ->
                ErrorReporter.addAlert("warning", "Failed to detect pings from #{target}")
                $scope.pinging = false

            return true

        $scope.searchDocs = () ->
            if not $scope.command.cmd.fun? or not $scope.docSearch or $scope.command.cmd.fun == ''
                $scope.docSearchResults = ''
                return true
            matching = _.filter($scope.docKeys, (key) ->
                return key.indexOf($scope.command.cmd.fun.toLowerCase()) != -1)
            matchingDocs = (key + "\n" + $scope.docs[key] + "\n" for key in matching)
            $scope.docSearchResults = matchingDocs.join('')
            return true

        $scope.isSearchable = () ->
            return $scope.docsLoaded

        $scope.testClick = (name) ->
            console.log "click #{name}"

        $scope.testFocus = (name) ->
            console.log "focus #{name}"

        $scope.removeLookupJidJobs = (job) ->
          return job.name != 'runner.jobs.lookup_jid'

        $scope.removeArgspecJobs = (job) ->
            return job.name.toLowerCase().indexOf('sys.argspec') != 0

        $scope.jobPresentationFilter = (job) ->
            return $scope.removeArgspecJobs(job) and $scope.removeLookupJidJobs(job)

        $scope.defaultVals = null

        $scope.setParameters = (requiredArgs, optionalArgs, defaultvals) ->
          $scope.command.requiredArgs = requiredArgs
          $scope.command.optionalArgs = optionalArgs
          $scope.defaultVals = defaultvals
          $scope.fillCommandArgs()
          return true

        $scope.commandArgs = []

        $scope.fillCommandArgs = () ->
          $scope.commandArgs = []
          $scope.command.cmd.arg = [""]
          _.each($scope.command.requiredArgs, (arg) ->
            $scope.commandArgs.push new ArgInfo(arg, true))
          _.each($scope.command.optionalArgs, (arg, index) ->
            $scope.commandArgs.push new ArgInfo(arg, false, $scope.defaultVals[index]))
          return true

        $scope.extractArgSpec = (returnFrom) ->
            required = []
            defaults = []
            defaults_vals = null
            argspec = null
            cmdData = $scope.command.cmd.fun?.split('.')
            return unless cmdData
            fun = $scope.command.cmd.fun
            if cmdData.length > 2
                keyData = [cmdData[1], cmdData[2]]
                fun = keyData.join('.')
                argspec = _.find(returnFrom, (commandKey) ->
                    return commandKey[fun]?
                )
            else
                argspec = _.find(returnFrom, (minion) ->
                    return minion[fun]?
                )

            if argspec?
                info = argspec[fun]
                if info.args?
                    required = (String(x) for x in info.args)
                    if info.defaults?
                        defaults = (required.pop() for arg in info.defaults)
                        defaults_vals = (String(x) for x in info.defaults)
                    else
                        defaults = null
                else
                    defaults = null
            else
                defaults = null
                required = null

            return {required: required, defaults: defaults, defaults_vals: defaults_vals}

        $scope.argSpec = () ->
          return unless $scope.getMinions()?.keys()?.length > 0
          cmd =
            module: $scope.command.cmd.fun
            client: 'minion'
            mode: 'sync'
            tgt: $scope.getMinions().keys()[0]

          SaltApiSrvc.signature($scope, cmd)
          .success (data, status, headers, config) ->
              argSpec = $scope.extractArgSpec(data.return?[0])
              $scope.setParameters(argSpec['required'], argSpec['defaults'], argSpec['defaults_vals'])
              return true
          .error (data, status, headers, config) ->
              $scope.setParameters(null, null, null)
              return true
          return true

        $scope.handleCommandChange = () ->
          $scope.searchDocs()
          $scope.argSpec()


        $scope.canExecuteCommands = () ->
          return not $scope.commandForm.$invalid and $scope.command.requiredArgs?

        $scope.getGrainsIfRequired = (mid) ->
            return if AppPref.get("fetchGrains", false)
            $scope.fetchGrains mid, false
            return true

        return true
    ]
