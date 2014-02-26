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

    return servicer
  ]
