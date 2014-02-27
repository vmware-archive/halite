angular.module("highstateCheckSrvc", ['appConfigSrvc', 'appUtilSrvc', 'saltApiSrvc', 'appPrefSrvc']).factory "HighstateCheck", 
  ['AppData', 'Itemizer', 'SaltApiSrvc', 'AppPref', '$q', (AppData, Itemizer, SaltApiSrvc, AppPref, $q) ->

    if !AppData.get('minions')?
      AppData.set('minions', new Itemizer())
    minions = AppData.get('minions')

    if !AppData.get('jobs')?
      AppData.set('jobs', new Itemizer())
    jobs = AppData.get('jobs')

    servicer =
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
        .success (data, status, headers, config) ->
          result = data.return?[0]
          if result
            job = $scope.startJob(result, cmd)
            job.commit($q).then (donejob) ->
              console.log donejob
              return
          return true
        .error (data, status, headers, config) ->
          console.log "error"
          cosole.log data
          return

    return servicer
  ]
