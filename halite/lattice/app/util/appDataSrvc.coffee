###
Application State Data Service
Provides shared global application state data
usage:

mainApp = angular.module("MainApp", [... 'appDataSrvc'])


mainApp.controller 'MyCtlr', ['$scope', ...,'AppData',
    ($scope,...,AppData) ->

    $scope.appData = AppData.getData()
    AppData.setData
        loggedIn: true


###


angular.module("appDataSrvc", ['appConfigSrvc', "appUtilSrvc"]).factory "AppData",
  ['Configuration', 'Itemizer', (Configuration, Itemizer) ->
    appData = {}

    base = Configuration.baseUrl
    JOBS = 'jobs'
    MINIONS = 'minions'
    EVENTS = 'events'
    COMMANDS = 'commands'

    appData[JOBS] = new Itemizer()
    appData[COMMANDS] = new Itemizer()
    appData[MINIONS] = new Itemizer()
    appData[EVENTS] = new Itemizer()

    servicer =
      getCommands: () ->
        return @get(COMMANDS)

      getJobs: () ->
        return @get(JOBS)

      getMinions: () ->
        return @get(MINIONS)

      getEvents: () ->
        return @get(EVENTS)

      getAll: () ->
        return appData

      update: (data) ->
        for own key, val of data
            appData[key] = val
        return appData

      clear: () ->
        appData = {}
        return appData

      get: (key) ->
        return appData[key]

      set: (key, val) ->
        appData[key] = val
        return val

      del: (key) ->
        if key of appData
          delete appData[key]
        return appData

      keys: () ->
        return (key for own key of appData)

      clearSaltData: () ->
        @set(COMMANDS, new Itemizer())
        @set(JOBS, new Itemizer())
        @set(MINIONS, new Itemizer())
        @set(EVENTS, new Itemizer())
        return

    return servicer
  ]
