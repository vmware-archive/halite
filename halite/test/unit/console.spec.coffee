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

        command = {}
        command.cmd = {}
        $scope.command = command

    it 'should perform case insensitive search', () ->
        $scope.command.cmd.fun = 'tEsT.PiNg'
        $scope.docSearch = true
        $scope.searchDocs()

        expect($scope.docSearchResults).toBe('test.ping\n' + docs['test.ping'] + '\n')

    it 'should perform exhaustive search', () ->
        $scope.command.cmd.fun = 'ping'
        $scope.docSearch = true
        $scope.searchDocs()


        expect($scope.docSearchResults).toContain('network')
        expect($scope.docSearchResults).toContain('test')

     it 'should perform correct search', () ->
         $scope.command.cmd.fun = 'network.ping'
         $scope.docSearch = true
         $scope.searchDocs()

         expect($scope.docSearchResults).not.toContain('test.ping')
         expect($scope.docSearchResults).toContain($scope.docs['network.ping'])

     it 'should clear test results when query is empty', () ->
         $scope.command.cmd.fun = 'network.ping'
         $scope.docSearch = true
         $scope.searchDocs()

         $scope.command.cmd.fun =  ''
         $scope.searchDocs()

         expect($scope.docSearchResults).toBe('')

     it 'should clear test results when query is undefined', () ->
         $scope.command.cmd.fun = 'network.ping'
         $scope.docSearch = true
         $scope.searchDocs()

         $scope.command.cmd.fun =  undefined
         $scope.searchDocs()

         expect($scope.docSearchResults).toBe('')

     it 'should clear test results when searchDocs is false', () ->
         $scope.command.cmd.fun = 'network.ping'
         $scope.docSearch = false
         $scope.searchDocs()

         expect($scope.docSearchResults).toBe('')
