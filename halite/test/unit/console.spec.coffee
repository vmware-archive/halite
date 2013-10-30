# jasmine

describe 'Console Controller Search Functionality', () ->

    $scope = null

    docs =
        'test.ping': 'foo'
        'network.ping': 'bar'

    beforeEach module('MainApp')

    beforeEach inject ($rootScope, $controller) ->
        $scope = $rootScope.$new()

        docKeys = ['test.ping', 'network.ping']

        $controller 'ConsoleCtlr',
            $scope: $scope

        $scope.docKeys = docKeys
        $scope.docs = docs

    it 'should perform case insensitive search', () ->
        $scope.searchStr = 'tEsT.PiNg'
        $scope.searchDocs()

        expect($scope.toRender).toBe('test.ping\n' + docs['test.ping'] + '\n')

    it 'should perform exhaustive search', () ->
        $scope.searchStr = 'ping'
        $scope.searchDocs()


        expect($scope.toRender).toContain('network')
        expect($scope.toRender).toContain('test')

     it 'should perform correct search', () ->
         $scope.searchStr = 'network.ping'
         $scope.searchDocs()

         expect($scope.toRender).not.toContain('test.ping')
         expect($scope.toRender).toContain($scope.docs['network.ping'])

