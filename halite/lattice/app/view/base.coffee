mainApp = angular.module("MainApp") #get reference to MainApp module

mainApp.controller 'BaseController', ['$scope', '$location', '$route', '$q', '$filter',
    '$templateCache', '$timeout',
    'Configuration','AppData', 'AppPref', 'Item', 'Itemizer',
    'Minioner', 'Resulter', 'Jobber', 'ArgInfo', 'Runner', 'Wheeler', 'Commander', 'Pagerage',
    'SaltApiSrvc', 'SaltApiEvtSrvc', 'SessionStore', 'ErrorReporter', 'HighstateCheck', 'EventDelegate', 'JobDelegate','$filter',
    ($scope, $location, $route, $q, $filter, $templateCache, $timeout, Configuration,
    AppData, AppPref, Item, Itemizer, Minioner, Resulter, Jobber, ArgInfo, Runner, Wheeler,
    Commander, Pagerage, SaltApiSrvc, SaltApiEvtSrvc, SessionStore, ErrorReporter, HighstateCheck, EventDelegate, JobDelegate ) ->


      if !AppData.get('commands')?
          AppData.set('commands', new Itemizer())
      $scope.commands = AppData.get('commands')

      if !AppData.get('jobs')?
          AppData.set('jobs', new Itemizer())
      $scope.jobs = AppData.get('jobs')

      if !AppData.get('minions')?
          AppData.set('minions', new Itemizer())
      $scope.minions = AppData.get('minions')

      if !AppData.get('events')?
          AppData.set('events', new Itemizer())
      $scope.events = AppData.get('events')

      $scope.alerts = () ->
        return ErrorReporter.getAlerts()

      $scope.closeAlert = (index) ->
          ErrorReporter.removeAlert(index)
          return

      $scope.addAlert = (type, msg) ->
        ErrorReporter.addAlert(type, msg)
        return

      $scope.fetchGrains = (target, noAjax = true) ->
          #target = if target then target else "*"
          cmd =
              mode: "async"
              fun: "grains.items"
              tgt: target
              expr_form: 'glob'

          if not target?
              minions = (minion.id for minion in $scope.minions.values() when minion.active is true)
              target = minions.join(',')
              cmd.tgt = target
              cmd.expr_form = 'list'


          $scope.graining = true if noAjax
          SaltApiSrvc.run($scope, [cmd])
          .success (data, status, headers, config) ->
              #$scope.graining = false
              result = data.return?[0]
              if result
                  job = JobDelegate.startJob(result, cmd)
                  job.commit($q).then (donejob) ->
                      $scope.assignGrains(donejob)
                      $scope.graining = false if noAjax
              return true
          .error (data, status, headers, config) ->
            ErrorReporter.addAlert("warning", "Failed to fetch Grains for #{target}")
            $scope.graining = false if noAjax
          return true

      $scope.assignGrains = (job) ->
          for {key: mid, val: result} in job.results.items()
              unless result.fail
                  grains = result.return
                  minion = JobDelegate.snagMinion(mid)
                  minion.grains.reload(grains, false)
          $scope.graining = false
          return job

      $scope.snagCommand = (name, cmds) -> #get or create Command
          unless $scope.commands.get(name)?
              $scope.commands.set(name, new Commander(name, cmds))
          return ($scope.commands.get(name))

      $scope.fetchActives = () ->
          cmd =
              mode: "async"
              fun: "runner.manage.present"

          $scope.statusing = true
          SaltApiSrvc.run($scope, [cmd])
          .success (data, status, headers, config) ->
              #$scope.statusing = false
              result = data.return?[0] #result is tag
              if result

                  job = JobDelegate.startRun(result, cmd) #runner result is tag
                  job.commit($q).then (donejob) ->
                      $scope.assignActives(donejob)
                      $scope.$broadcast("Marshall")
                      # console.log $scope
                      # console.log("past broadcast")

              return true
          .error (data, status, headers, config) ->
            ErrorReporter.addAlert("warning", "Failed to detect minions present")
            $scope.statusing = false
          return true

      $scope.setActives = (activeMinions) ->
        inactiveMinions = _.difference($scope.minions.keys(), activeMinions)
        for mid in activeMinions
          minion = JobDelegate.snagMinion(mid)
          minion.activize()
        for mid in inactiveMinions
          minion = JobDelegate.snagMinion(mid)
          minion.unlinkJobs()
          minion.deactivize()

      $scope.assignActives = (job) ->
          for {key: mid, val: result} in job.results.items()
              unless result.fail
                  $scope.setActives(result.return)
                  # for mid in status.up
                  #     minion = $scope.snagMinion(mid)
                  #     minion.activize()
                  #     mids.push mid
                  # for mid in status.down
                  #     minion = $scope.snagMinion(mid)
                  #     minion.deactivize()
                  #     mids.push mid
                  # for key in $scope.minions.keys()
                  #     unless key in mids
                  #         minion = $scope.snagMinion(key)
                  #         minion.unlinkJobs()
                  # $scope.minions?.filter(mids) #remove non status minions
          $scope.statusing = false
          return job

        $scope.openEventStream = (callback, eventType="salt/") ->
            $scope.eventing = true
            $scope.eventPromise = SaltApiEvtSrvc.events($scope,
                callback, eventType)
            .then (data) ->
                # console.log "Opened Event Stream: "
                #console.log data
                $scope.$emit('Activate')
                $scope.eventing = false
            , (data) ->
                console.log "Error Opening Event Stream"
                #console.log data
                if SessionStore.get('loggedIn') == false
                  ErrorReporter.addAlert("danger", "Cannot open enevt stream! Please login!")
                else
                  ErrorReporter.addAlert("danger", "Cannot open event stream!")
                $scope.eventing = false
                return data
            return true

      $scope.closeEventStream = () ->
          #console.log "Closing Event Stream"
          SaltApiEvtSrvc.close()
          return true

      $scope.clearSaltData = () ->
          AppData.set('commands', new Itemizer())
          $scope.commands = AppData.get('commands')
          AppData.set('jobs', new Itemizer())
          $scope.jobs = AppData.get('jobs')
          AppData.set('minions', new Itemizer())
          $scope.minions = AppData.get('minions')
          AppData.set('events', new Itemizer())
          $scope.events = AppData.get('events')

      $scope.authListener = (event, loggedIn) ->
          #console.log "Received #{event.name}"
          #console.log event
          if loggedIn
              $scope.openEventStream($scope.eventDispatch)
          else
              $scope.closeEventStream()
              $scope.clearSaltData()
          return true

      $scope.activateListener = (event) ->
          # console.log "Received #{event.name}"
          #console.log event
          $scope.fetchActives()
          $scope.preloadJobCache() if AppPref.get("preloadJobCache", false)

      $scope.eventDispatch = (edata) ->
        return if edata.data?.data?.ret?.name == 'event.fire_master'
        # console.log "In dispatch"
        if edata.tag.split('/')[0] == "salt"
          if edata.tag.split('/')[1] == 'presense'
            $scope.setActives(edata.data.present) if edata.data.present?
          else
            EventDelegate.processSaltEvent($scope, edata)
        else
          # console.log edata
          return true
        return true

      $scope.docsLoaded = false
      $scope.docKeys = []
      $scope.docSearchResults = ''
      $scope.docs = {}

      $scope.isLoggedIn = () ->
        SessionStore.get('loggedIn')

      $scope.marshallListener = (event) ->
        # console.log "Received #{event.name} ml"
        #console.log event
        $scope.fetchGrains() if AppPref.get("fetchGrains", false)
        $scope.fetchDocs()
        $scope.highstatePoller()
        # $scope.openEventStream($scope.eventDispatch, 'edgenuity/')

      $scope.highstatePoller = () ->
        # Auto Check
        return unless HighstateCheck.isHighstateCheckEnabled()
        HighstateCheck.makeHighStateCall($scope)
        $timeout $scope.highstatePoller, HighstateCheck.getTimeoutMilliSeconds()
        return

      $scope.checkHighstateConsistency = () ->
        # On Demand Checks
        HighstateCheck.makeHighStateCall($scope)
        return

      $scope.isPerformingConsistencyCheck = () ->
        return HighstateCheck.isChecking()

      $scope.isCheckingForHighstateConsistency = () ->
        return HighstateCheck.isHighstateCheckEnabled()

      $scope.fetchDocsDone = (donejob) ->
          results = donejob.results
          minions = results._data
          minion_with_result = _.find(minions, (minion) ->
              minion.val.retcode == 0)
          if minion_with_result?
              $scope.docs = minion_with_result.val.return
              $scope.docKeys = for key, value of $scope.docs
                  "#{key.toLowerCase()}"
              $scope.docsLoaded = true
          else
              ErrorReporter.addAlert("warning", "Docs not loaded. Please check minions and retry")
          return

        $scope.fetchDocsFailed = () ->
            ErrorReporter.addAlert("warning", "Failed to fetch docs. Please check system and retry")

        $scope.fetchDocs = () ->
            return unless $scope.minions?.keys()?.length > 0
            command =
                fun: 'sys.doc'
                mode: 'async'
                tgt: $scope.minions.keys()[0]
                expr_form: 'glob'

            # command = $scope.snagCommand($scope.humanize(commands), commands)
            SaltApiSrvc.run($scope, command)
            .success (data, status, headers, config) ->
                result = data.return?[0] #result is a tag
                if result
                    job = JobDelegate.startJob(result, command) #runner result is a tag
                    job.resolveOnAnyPass = true
                    job.commit($q).then($scope.fetchDocsDone, $scope.fetchDocsFailed)
                    return true
            .error (data, status, headers, config) ->
                ErrorReporter.addAlert("warning", "HTTP Fetch Docs Failed!")
                return false
            return true

      $scope.$on('ToggleAuth', $scope.authListener)
      $scope.$on('Activate', $scope.activateListener)
      $scope.$on('Marshall', $scope.marshallListener)

      if not SaltApiEvtSrvc.active and SessionStore.get('loggedIn') == true
          $scope.openEventStream($scope.eventDispatch)

      return true
    ]
