###
Service to handle event processing.
###
angular.module("eventSrvc", ['appConfigSrvc', 'appUtilSrvc', 'errorReportingSrvc', 'appPrefSrvc', 'jobSrvc']).factory "EventDelegate",
  ['AppData', 'Itemizer', 'AppPref', '$q', 'ErrorReporter', 'JobDelegate', (AppData, Itemizer, AppPref, $q, ErrorReporter, JobDelegate) ->

    servicer =
      processKeyEvent: (edata) ->
        data = edata.data
        mid = data.id
        minion = JobDelegate.snagMinion(mid)
        if data.result is true
          if data.act is 'delete'
            minion.unlinkJobs()
            minions.del(mid)
        return minion
      processMinionEvent: ($scope, mid, edata) ->
        minion = JobDelegate.snagMinion(mid)
        minion.processEvent(edata)
        minion.activize()
        $scope.fetchGrains(mid) if AppPref.get('fetchGrains', false)
        return minion
      processWheelEvent: (jid, kind, edata) ->
        job = AppData.getJobs().get(jid)
        job.processEvent(edata)
        data = edata.data
        if kind == 'new'
          job.processNewEvent(data)
        else if kind == 'ret'
          job.processRetEvent(data)
        return job
      processRunEvent: ($scope, jid, kind, edata) ->
        job = AppData.getJobs().get(jid)
        job.processEvent(edata)
        data = edata.data
        if kind == 'new'
          job.processNewEvent(data)
        else if kind == 'ret'
          if data.fun == 'runner.jobs.lookup_jid'
            $scope.processLookupJID(data)
          job.processRetEvent(data)
        return job
      processJobEvent: (jid, kind, edata) ->
        job = AppData.getJobs().get(jid)
        job.processEvent(edata)
        data = edata.data
        if kind == 'new'
          job.processNewEvent(data)
        else if kind == 'ret'
          minion = JobDelegate.snagMinion(data.id)
          minion.activize() #since we got a return then minion must be active
          job.linkMinion(minion)
          job.processRetEvent(data)
          job.checkDone()
        else if kind == 'prog'
          minion = JobDelegate.snagMinion(data.id)
          job.linkMinion(minion)
          job.processProgEvent(edata)
        return job
      stamp: () ->
        date = new Date()
        stamp = ["/#{date.getUTCFullYear()}",
                 "-#{('00' + date.getUTCMonth()).slice(-2)}",
                 "-#{('00' + date.getUTCDate()).slice(-2)}",
                 "T#{('00' + date.getUTCHours()).slice(-2)}",
                 ":#{('00' + date.getUTCMinutes()).slice(-2)}",
                 ":#{('00' + date.getUTCSeconds()).slice(-2)}",
                 ".#{('000' + date.getUTCMilliseconds()).slice(-3)}"].join("")
        return stamp
      processSaltEvent: ($scope, edata) ->
        # console.log "Process Salt Event: "
        # console.log edata
        if not edata.data._stamp?
          edata.data._stamp = @stamp()
        edata.utag = [edata.tag, edata.data._stamp].join("/")
        edata.data.stamp = edata.data._stamp # fixes ng 1.2 error expression private data
        AppData.getEvents().set(edata.utag, edata)
        parts = edata.tag.split("/") # split on "/" character
        if parts[0] is 'salt'
          if parts[1] is 'job'
            jid = parts[2]
            if jid != edata.data.jid
              ErrorReporter.addAlert("danger", "Bad job event")
              return false
            JobDelegate.snagJob(jid, edata.data)
            kind = parts[3]
            @processJobEvent(jid, kind, edata)

          else if parts[1] is 'run'
            jid = parts[2]
            if jid != edata.data.jid
              ErrorReporter.addAlert("danger", "Bad run event")
              return false
            JobDelegate.snagRunner(jid, edata.data)
            kind = parts[3]
            @processRunEvent($scope, jid, kind, edata)

          else if parts[1] is 'wheel'
            jid = parts[2]
            if jid != edata.data.jid
              ErrorReporter.addAlert("danger", "Bad wheel event")
              return false
            JobDelegate.snagWheel(jid, edata.data)
            kind = parts[3]
            @processWheelEvent(jid, kind, edata)

          else if parts[1] is 'minion' or parts[1] is 'syndic'
            mid = parts[2]
            if mid != edata.data.id
              ErrorReporter.addAlert("warning", "Bad minion event")
              return false
            @processMinionEvent($scope, mid, edata)

         else if parts[1] is 'key'
           @processKeyEvent(edata)

        return edata
    return servicer
  ]
