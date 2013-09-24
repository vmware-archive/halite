mainApp = angular.module("MainApp")

mainApp.controller 'ProjectCtlr', [
    '$scope', '$location', '$route','Configuration', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, SaltApiSrvc) ->
        $scope.errorMsg = ""
        
        
        $scope.totalItems = 64
        $scope.currentPage = 1
        $scope.maxSize = 5
        $scope.itemsPerPage = 10
  
        $scope.setPage = (pageNo) ->
            $scope.currentPage = pageNo;
            
        $scope.displayPage = (pageNo) ->
            $scope.stuff = "info from page" + pageNo
        
        return true
]
