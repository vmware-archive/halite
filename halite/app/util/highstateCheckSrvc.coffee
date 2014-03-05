###
Service used to facilitate checking for Highstate consistency.
This service defines logic needed to make the call equivalent to
salt \* state.highstate test=True
It also defines methods to parse and process the event data returned in response
to the highstate test call.
There are methods that are used to query the configuration and check if
automatic polling for highstate checks is enabled and ones that get the timeout
value and convert it to milliseconds.
This service is intended to be called from a controller.
###
angular.module("highstateCheckSrvc", ['appConfigSrvc', 'appUtilSrvc', 'saltApiSrvc', 'appPrefSrvc']).factory "HighstateCheck",
  ['AppData', 'Itemizer', 'SaltApiSrvc', 'AppPref', '$q', (AppData, Itemizer, SaltApiSrvc, AppPref, $q) ->

    if !AppData.get('minions')?
      AppData.set('minions', new Itemizer())
    minions = AppData.get('minions')

    if !AppData.get('jobs')?
      AppData.set('jobs', new Itemizer())
    jobs = AppData.get('jobs')


    class HighStateStatus
      constructor: (@dirty = false, @messages = []) ->

    isCheckingHighstateConsistency = false

    servicer =
      clearOldHighstateStatuses: () ->
        minion.highstateStatus = new HighStateStatus() for minion in minions.values()
        return
      highstateDirtyComments: (stateData) ->
        retVal = []
        for mangledName, val of stateData
          {comment, result} = val
          if result isnt true
            # Needs highstate
            retVal.push(comment)
        return retVal
      processHighstateCheckReturns: (items) ->
        @clearOldHighstateStatuses()
        for i, item of items
          {key, val} = item
          result = @highstateDirtyComments val.return
          if result.length > 0
            # Assign dirty status to minion
            minions.get(key)?.highstateStatus = new HighStateStatus(true, result)
        return
      isHighstateCheckEnabled: () ->
        highStateCheck = AppPref.get('highStateCheck')
        return highStateCheck.performCheck
      getTimeoutMilliSeconds: () ->
        highStateCheck = AppPref.get('highStateCheck')
        return highStateCheck.intervalSeconds * 1000
      isChecking: () ->
        return isCheckingHighstateConsistency
      makeHighStateCall: ($scope) ->
        isCheckingHighstateConsistency = true
        # Call highstate with test=True
        tgt = minions.keys().join(',')

        cmd =
          fun: 'state.highstate'
          tgt: tgt
          expr_form: 'list'
          mode: 'async'
          arg: [true]

        SaltApiSrvc.run($scope, [cmd])
        .success (data, status, headers, config) =>
          result = data.return?[0]
          if result.jid?
            job = $scope.startJob(result, cmd)
            job.commit($q).then (donejob) =>
              @processHighstateCheckReturns donejob.results.items()
              isCheckingHighstateConsistency = false
              return
          return true
        .error (data, status, headers, config) ->
          isCheckingHighstateConsistency = false
          console.log "error"
          console.log data
          return

    return servicer
  ]
