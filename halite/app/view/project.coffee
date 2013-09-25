mainApp = angular.module("MainApp")

mainApp.controller 'ProjectCtlr', [
    '$scope', '$location', '$route','Configuration', 'SaltApiSrvc',
    ($scope, $location, $route, Configuration, SaltApiSrvc) ->
        $scope.errorMsg = ""
        
        
        $scope.paginator =
            page: 1
            itemCount: 64
            perPage: 10
            pagerLimit: 5
        
        $scope.newPaginator = () ->
            return angular.copy($scope.paginator)
            
        $scope.itemOffset =  (page, perPage) ->
            return (Math.max(page-1,0) * perPage)
            
            
        
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
