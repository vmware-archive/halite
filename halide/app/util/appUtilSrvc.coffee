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
OData class  used to provide ordered data object with keyed lookup
where the store value is not polluted by the lookup key 
and also provides item list that is suitable for angular ng-repeat.
Each item in an OData instance is an Item object of the form:
{ "key": key, "val": val}
Items can be accessed by item key but the order of entry or sort is preserved.

Since each item is not a primitive type but an object, ng-repeat will be
able to reference it as a model target 

###

class OData
    constructor: (stuff, deep) ->
        @_data = {} # data object maps keys to values that are item objects
        @_keys = [] # list of keys
        @update(stuff, deep)
        
    get: (key, tag) ->
        if tag
            return @_data[key]?.val[tag]
        else
            return @_data[key]?.val
    
    getItem: (key) ->
        return @_data[key]
        
    set: (key, val, tag) ->
        if key in @_keys
            if tag
                @_data[key].val[tag] = val
            else
                @_data[key].val = val
        else
            @_keys.push key
            if tag
                @_data[key] = new Item(key, {})
                @_data[key].val[tag] = val
            else
                @_data[key] = new Item(key, val)
        return @
    
    _isItem: (item) ->
        if item instanceof Item
            return true
        if angular.isObject(item) and 
            not angular.isArray(item) and
            "key" of item and 
            "val" of item
                return true
        return false
        
    _isItemList: (items) ->
        if not angular.isArray(items)
            return false
        if not items.length
            return false
        for item in items
            if not @_isItem(item)
                return false
        return true
    
    deepSet: (key, val) ->
        if @_isItemList(val)
            odata = new OData
            for item in val
                odata.deepSet(item.key, item.val)
            @set key, odata
        else if angular.isObject(val) and not angular.isArray(val) # not array object
            odata = new OData()
            for own k, v of val
               odata.deepSet(k,v)
            @set key, odata
        else
            @set key, val
        return @
            
    del: (key, tag) ->
        if key in @_keys
            if tag
                delete @_data[key].val[tag]
            else
                @_keys = (_key for _key in @_keys when _key != key)
                delete @_data[key]
        return @
    
    clear: () ->
        @_data = {}
        @_keys = []
        return @
    
    items: (deep) ->
        items = []
        for key in @_keys
            if deep and (@_data[key].val instanceof OData)
                items.push (new Item(key, @_data[key].val.items(deep)))
            else
                items.push @_data[key]
        return items
        
    keys: () ->
        return @_keys
        
    values: () ->
        return (@_data[key].val for key in @_keys)
        
    sort: (sorter, deep) ->
        @_keys.sort sorter
        if deep
            for key in @_keys
                if @_data[key].val instanceof OData
                    @_data[key].val.sort(sorter, deep)
        return @_keys
    
    update: (stuff, deep) ->
        if stuff?
            if @_isItemList(stuff)
                for item in stuff
                    if deep
                        @deepSet item.key, item.val
                    else
                        @set item.key, item.val
            else if angular.isObject(stuff) and not angular.isArray(stuff) 
                for own key, val of stuff
                    if deep
                        @deepSet key, val
                    else
                        @set key, val 
        return @
    
    reload: (stuff, deep) ->
        @clear()
        @update(stuff, deep)
        return @
    
    unitemize: () ->  
        data = {}
        for item in @items()
            if item.val instanceof OData
                data[item.key] = item.val.unitemize()
            else
                data[item.key] = item.val
        return data
    
    filter: (keys) ->
        for key in @_keys
            if key not in keys
                delete @_data[key]
        @_keys = (_key for _key in @_keys when _key in keys)
                
        return @
        

appUtilSrvc.factory "OrderedData", 
    () -> 
        return OData

appUtilSrvc.value "OData", OData

        

