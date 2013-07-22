###
Generic app utility services

OrdereMap service return new instance of OMap

###


appUtilSrvc = angular.module("appUtilSrvc", [])

###
Prototype object to provided ordered data object suitable for angular ng-repeat
Each item in an OData instance is an object of the form { "key": key, "val": val}
_items can be accessed by key but the order of entry or sort is preserved

Since each item is an object which is not a primitive type 
angular ng-repeat will not lose its reference

###



class OData
    constructor: (stuff) ->
        @_data = {} # data object maps keys to item objects
        @_items = [] # list of item objects {key: key, val: val}
        @update(stuff)
        
    get: (key) ->
        return @_data[key]
        
    set: (key, val) ->
        if key?
            if key of @_data
                @_data[key].val = val
            else
                @_items.push
                    key: key
                    val: val
                @_data[key] = @_items[@_items.length - 1]
            
        return @get(key)
            
    del: (key) ->
        if key of @_data
            @_items = (item for item in @_items when key != item.key)
            delete @_data[key]
            return true
        else
            return false
    
    clear: () ->
        @_data = {}
        @_items = []
        return true
    
    items: () ->
        return @_items
        
    keys: () ->
        return (item.key for item in @_items)
        
    values: () ->
        return (item.val for item in @_items)
        
    sort: (sorter) ->
        keys = @keys().sort(sorter)
        @_items = (@_data[key] for key in keys)
        return @_items
    
    update: (stuff) ->
        if stuff?
            if angular.isArray(stuff) #array is object
                for item in stuff
                    @set(item.key, item.val)
            else if angular.isObject(stuff) #not array 
                for key, val of stuff
                    @set(key,val)
            
        
        return @_items 
        

appUtilSrvc.factory "OrderedData", 
    () -> 
        return OData