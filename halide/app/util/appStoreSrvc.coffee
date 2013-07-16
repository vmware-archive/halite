###
Persistent Data Service using Web Storage LocalStorage and SessionStorage
Each is given a different factory.

Provides shared global application persistent data

.set  applys JSON.stringify to its val so that objects can be stored
.get  applys JSON.parse to to its return to inverse set

If the value is a string then the other forms 
.store.keystring
.store['keystring']
to get an set values

usage:

mainApp = angular.module("MainApp", [... 'appStoreSrvc'])


mainApp.controller 'MyCtlr', ['$scope', ...,'LocalStore',
    ($scope,...,LocalStore) ->
    
    if LocalStore.exists()
        LocalStore.store.first = "John"
        $scope.first = LocalStore.store.first
        LocalStore.set('last', "Smith")
        $scope.last = LocalStore.get('last')
    
Simailarly for SessionStore

###


angular.module("appStoreSrvc", [])
.factory "LocalStore", 
    () -> 
        servicer =
            store: localStorage
            exists: () ->
                return localStorage?
            clear: () ->
                return localStorage.clear()
            len: () ->
                return localStorage.length()
            key: (index) ->
                return localStorage.key(index)
            get: (key) ->
                return JSON.parse localStorage.getItem(key)
            set: (key,val) ->
                return localStorage.setItem key, JSON.stringify(val)
            remove: (key) ->
                return localStorage.removeItem(key)
        return servicer

.factory "SessionStore", 
    () -> 
        servicer =
            store: sessionStorage
            exists: () ->
                return sessionStorage?
            clear: () ->
                return sessionStorage.clear()
            len: () ->
                return sessionStorage.length()
            key: (index) ->
                return sessionStorage.key(index)
            get: (key) ->
                return JSON.parse sessionStorage.getItem(key)
            set: (key,val) ->
                return sessionStorage.setItem key, JSON.stringify(val)
            remove: (key) ->
                return sessionStorage.removeItem(key)
        return servicer