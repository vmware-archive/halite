###
Salt Service

Exposes Salt's data model.

Queries salt for minions at boot time.
###


angular.module("saltSrvc", ["saltApiSrvc", "appDataSrvc"]).factory "Salt",
  ['FetchActives', 'AppData', (FetchActives, AppData) ->

    servicer =
      boot: (successCallback, errorCallback) =>
        FetchActives.fetchActives({}, @).then (status) =>
          successCallback(servicer)
        , (status) =>
          errorCallback(@)
        return
      getMinions: () =>
        return AppData.getMinions()
      getJobs: () =>
        return AppData.getJobs()
      getCommands: () =>
        return AppData.getCommands()
    return servicer
  ]
