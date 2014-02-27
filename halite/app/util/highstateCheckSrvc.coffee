angular.module("highstateCheckSrvc", ['appConfigSrvc', 'appUtilSrvc', 'saltApiSrvc', 'appPrefSrvc']).factory "HighstateCheck",
  ['AppData', 'Itemizer', 'SaltApiSrvc', 'AppPref', '$q', (AppData, Itemizer, SaltApiSrvc, AppPref, $q) ->

    if !AppData.get('minions')?
      AppData.set('minions', new Itemizer())
    minions = AppData.get('minions')

    if !AppData.get('jobs')?
      AppData.set('jobs', new Itemizer())
    jobs = AppData.get('jobs')

    servicer =
      isHighstateDirty: (stateData) ->
        retVal = []
        for mangledName, val of stateData
          {comment, result} = val
          if result isnt true
            # Needs highstate check
            retVal.push(comment)
        return retVal
      processHighstateCheckReturns: (items) ->
        for i, item of items
          {key, val} = item
          result = @isHighstateDirty val.return
          if result.length > 0
            # Assign dirty status to minion
            console.log "Dirty Minion is #{key}"
            console.log minions.get(key)
            console.log result
        return
      isHighstateCheckEnabled: () ->
        highStateCheck = AppPref.get('highStateCheck')
        return highStateCheck.performCheck
      makeHighStateCall: ($scope) ->
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
          if result
            job = $scope.startJob(result, cmd)
            job.commit($q).then (donejob) =>
              @processHighstateCheckReturns donejob.results.items()
              return
          return true
        .error (data, status, headers, config) ->
          console.log "error"
          console.log data
          return

    return servicer
  ]
