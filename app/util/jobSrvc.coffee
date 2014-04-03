###
Service to handle Jobs, Minions and Wheel interaction.
Exposes functions that create a new Job / Wheel / Minioner
that can listen for events and update in memory data accordingly.
###
angular.module("jobSrvc", ['appUtilSrvc']).factory "JobDelegate",
  ['AppData', 'Itemizer', 'Wheeler', 'Jobber', 'Minioner', 'Runner',
  (AppData, Itemizer, Wheeler, Jobber, Minioner, Runner) ->

    if !AppData.get('events')?
      AppData.set('events', new Itemizer())
    events = AppData.get('events')

    servicer =
      startWheel: (data, cmd) ->
        #console.log "Start Wheel #{$scope.humanize(cmd)}"
        #console.log data
        parts = data.tag.split("/")
        jid = parts[2]
        job = @snagWheel(jid, cmd)
        return job
      startRun: (data, cmd) ->
        #console.log "Start Run #{$scope.humanize(cmd)}"
        #console.log data
        parts = data.tag.split("/")
        jid = parts[2]
        job = @snagRunner(jid, cmd)
        return job
      startJob: (result, cmd) ->
        #console.log "Start Job #{$scope.humanize(cmd)}"
        #console.log result
        jid = result.jid
        job = @snagJob(jid, cmd)
        job.initResults(result.minions)
        return job
      snagWheel: (jid, cmd) -> #get or create Wheeler
        if not AppData.getJobs().get(jid)?
          job = new Wheeler(jid, cmd)
          AppData.getJobs().set(jid, job)
        return (AppData.getJobs().get(jid))
      snagRunner: (jid, cmd) -> #get or create Runner
        if not AppData.getJobs().get(jid)?
          job = new Runner(jid, cmd)
          AppData.getJobs().set(jid, job)
        return (AppData.getJobs().get(jid))
      snagMinion: (mid) -> # get or create Minion
        if not AppData.getMinions().get(mid)?
          AppData.getMinions().set(mid, new Minioner(mid))
        return (AppData.getMinions().get(mid))
      snagJob: (jid, cmd) -> #get or create Jobber
        if not AppData.getJobs().get(jid)?
          job = new Jobber(jid, cmd)
          AppData.getJobs().set(jid, job)
        return (AppData.getJobs().get(jid))
    return servicer
  ]
