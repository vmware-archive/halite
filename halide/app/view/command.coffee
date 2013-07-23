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

        # Hack to workaround angular not reusing existing <input> elements;
        # when model changes element is destroyed and replaced. this decouples
        # the array used to build the DOM elements from the array in the model
        $scope.tmpArg = []
        updateTmpArgs = () ->
            $scope.tmpArg = (arg for arg in $scope.lowstate.arg)
        updateTmpArgs() # initial populate

        $scope.addArg = () ->
            $scope.lowstate.arg.push('')
            updateTmpArgs()

        getLowstate = (obj) ->
            return [{
                client: obj.client,
                tgt: obj.tgt,
                fun: obj.fun,
                arg: (arg for arg in obj.arg when arg isnt ''),
            }]

        $scope.act = () ->
            $scope.saltApiCallPromise = SaltApiSrvc.act($scope,
                getLowstate($scope.lowstate))
            $scope.saltApiCallPromise.success((data) ->
                $scope.ret = data.return[0]
                return true
            )

        return true
]
