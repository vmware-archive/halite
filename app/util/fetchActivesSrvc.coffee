angular.module("fetchActivesSrvc", ['appConfigSrvc', 'appUtilSrvc', 'saltApiSrvc', 'jobSrvc']).factory "FetchActives",
  ['AppData', 'Itemizer', 'SaltApiSrvc', '$q', 'JobDelegate', (AppData, Itemizer, SaltApiSrvc, $q, JobDelegate) ->

    servicer =
      setActives: (activeMinions) ->
        inactiveMinions = _.difference(AppData.getMinions().keys(), activeMinions)
        for mid in activeMinions
          minion = JobDelegate.snagMinion(mid)
          minion.activize()
        for mid in inactiveMinions
          minion = JobDelegate.snagMinion(mid)
          minion.unlinkJobs()
          minion.deactivize()
        return
      assignActives: (job) ->
        for {key: mid, val: result} in job.results.items()
          @setActives(result.return) unless result.fail
        return
      fetchActives: ($scope, salt) ->
        defer = $q.defer()
        cmd =
          mode: "async"
          fun: "runner.manage.present"
        SaltApiSrvc.run($scope, [cmd])
        .success (data, status, headers, config) =>
          result = data.return?[0]
          if result
            job = JobDelegate.startRun(result, cmd)
            if job.done
              @assignActives(job)
              defer.resolve({'success': true})
              return # early return
            job.commit($q).then (donejob) =>
              @assignActives(donejob)
              defer.resolve({'success': true})
              return
          return
        .error (error) ->
          salt.fetchActivesFailed()
          defer.reject({'success': false})
          return
        return defer.promise
    return servicer
  ]
