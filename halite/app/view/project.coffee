mainApp = angular.module("MainApp")

mainApp.controller 'ProjectCtlr', ['$scope', '$location', '$route', '$q', '$filter',
    '$templateCache',
    'Configuration','AppData', 'AppPref', 'Item', 'Itemizer',
    'Minioner', 'Resulter', 'Jobber', 'ArgInfo', 'Runner', 'Wheeler', 'Commander', 'Pagerage',
    'SaltApiSrvc', 'SaltApiEvtSrvc', 'SessionStore', '$filter',
    ($scope, $location, $route, $q, $filter, $templateCache, Configuration,
    AppData, AppPref, Item, Itemizer, Minioner, Resulter, Jobber, ArgInfo, Runner, Wheeler,
    Commander, Pagerage, SaltApiSrvc, SaltApiEvtSrvc, SessionStore ) ->
        $scope.errorMsg = ""

        return true
]
