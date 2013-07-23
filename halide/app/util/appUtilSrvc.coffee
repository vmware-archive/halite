###
Generic app utility services

OrdereMap service return new instance of OMap

###


appUtilSrvc = angular.module("appUtilSrvc", [])



###
Item class used as item for OrderedData
Creates object of form { key: key, val: val}
###

class Item
    constructor: (@key, @val) ->
        
        

###
OData class used to provide ordered data object suitable for angular ng-repeat
Each item in an OData instance is an Item object of the form { "key": key, "val": val}
items can be accessed by key but the order of entry or sort is preserved

Since each item is not a primitive type but an object, ng-repeat will be
able to reference it as a model
###

class OData
    constructor: (stuff) ->
        @_data = {} # data object maps keys to values that are item objects
        @_keys = [] # list of keys
        @update(stuff)
        
    get: (key) ->
        return @_data[key]
        
    set: (key, val) ->
        if key in @_keys
            @_data[key].val = val
        else
            @_keys.push key
            @_data[key] = new Item(key, val)
        return @_data[key]
            
    del: (key) ->
        if key in @_keys
            @_keys = (_key for _key in @_keys when _key != key)
            delete @_data[key]
        return @
    
    clear: () ->
        @_data = {}
        @_keys = []
        return @
    
    items: () ->
        return (@_data[key] for key in @_keys)
        
    keys: () ->
        return @_keys
        
    values: () ->
        return (@_data[key].val for key in @_keys)
        
    sort: (sorter) ->
        @_keys.sort sorter
        return @_keys
    
    update: (stuff) ->
        if stuff?
            if angular.isArray(stuff) #array is object
                for item in stuff
                    @set item.key, item.val
            else if angular.isObject(stuff) #not array 
                for own key, val of stuff
                    @set key, val 
        return @
    
    reload: (stuff) ->
        @clear()
        @update(stuff)
        return @
    
    deepSet: (key, val) ->
        if angular.isObject(val) and not angular.isArray(val) # not array
            odata = new OData()
            for own k, v of val
                @set key, odata.deepSet(k,v)
        else
            @set key, val
        return @
    
    deepSort: (sorter) ->
        @_keys.sort sorter
        for key in @_keys
            if @_data[key] instanceof OData
                @_data[key].deepSort(sorter)
        return @_keys
        
    deepUpdate: (stuff) ->
        if stuff?
            if angular.isArray(stuff) #array object
                for item in stuff
                    @deepSet item.key, item.val
            else if angular.isObject(stuff) #object but not array 
                for own key, val of stuff
                    @deepSet key, val
        return @
    
    deepReload: (stuff) ->
        @clear()
        @deepUpdate(stuff)
        return @
    
    unitemize: () ->  
        data = {}
        for item in @items()
            if item.val instanceof OData
                data[item.key] = item.val.unitemize()
            else
                data[item.key] = item.val
        return data

appUtilSrvc.factory "OrderedData", 
    () -> 
        return OData