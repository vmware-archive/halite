angular.module("fetchActivesSrvc", ['appConfigSrvc', 'appUtilSrvc', 'saltApiSrvc']).factory "FetchActives", 
  ['AppData', 'Itemizer', 'SaltApiSrvc', '$q', (AppData, Itemizer, SaltApiSrvc, $q) ->

    if !AppData.get('minions')?
      AppData.set('minions', new Itemizer())
    minions = AppData.get('minions')

    servicer =
      fetchActives: ($scope, success, error) ->
        cmd =
          mode: "async"
          fun: "runner.manage.present"
        $scope.fetchActivesCmd = cmd
        SaltApiSrvc.run($scope, [cmd])

    return servicer
  ]