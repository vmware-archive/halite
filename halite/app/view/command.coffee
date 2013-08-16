mainApp = angular.module("MainApp")

mainApp.controller 'CommandCtlr', [
    '$scope', '$location', '$route','Configuration', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, SaltApiSrvc) ->
        $scope.errorMsg = ""
        $scope.ret = {}
        $scope.lowstate = {
            client: 'local',
            tgt: '*',
            fun: '',
            arg: [''],
        }

        $scope.addArg = () ->
            $scope.lowstate.arg.push('')

        getLowstate = (obj) ->
            return [{
                client: obj.client,
                tgt: obj.tgt,
                fun: obj.fun,
                arg: (arg for arg in obj.arg when arg isnt ''),
            }]

        $scope.act = () ->
            $scope.saltApiCallPromise = SaltApiSrvc.run($scope,
                getLowstate($scope.lowstate))
            $scope.saltApiCallPromise.success((data) ->
                $scope.ret = data.return[0]
                return true
            )

        return true
]
