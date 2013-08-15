###
Generic app utility services

OrdereMap service return new instance of OMap

###


appUtilSrvc = angular.module("appUtilSrvc", [])



###
Item class used as item for Itemizer
Creates object of form { key: key, val: val}
###

class Item
    constructor: (@key, @val) ->
    
appUtilSrvc.value "Item", Item

###
Itemizer class  used to provide ordered data object with keyed lookup
and also provides item list that is suitable for angular ng-repeat scoping.
Each item in an Itemizer instance is an Item object of the form:
{ "key": key, "val": val}
Items can be accessed by item key but the order of entry or sort is preserved.

Since each item is not a primitive type but an object, ng-repeat will be
able to reference it as a model target.

Angular 1.15+ provides the ng-repeat track by which means one does not
need the itemizations but version 1.0X of angular do not have this functionality
###

class Itemizer
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
    
    deepSet: (key, val, update) ->
        itemizer = @_data[key]?.val
        if @_isItemList(val)
            if not (itemizer instanceof Itemizer) or not update
                itemizer = new Itemizer
                @set key, itemizer
            for item in val
                itemizer.deepSet item.key, item.val, update
        else if angular.isObject(val) and not angular.isArray(val) # not array object
            if not (itemizer instanceof Itemizer) or not update
                itemizer = new Itemizer()
                @set key, itemizer
            for own k, v of val
               itemizer.deepSet k, v, update
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
            if deep and (@_data[key].val instanceof Itemizer)
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
                if @_data[key].val instanceof Itemizer
                    @_data[key].val.sort(sorter, deep)
        return @_keys
    
    update: (stuff, deep) ->
        if stuff?
            if @_isItemList(stuff)
                for item in stuff
                    if deep
                        @deepSet item.key, item.val, true
                    else
                        @set item.key, item.val
            else if angular.isObject(stuff) and not angular.isArray(stuff) 
                for own key, val of stuff
                    if deep
                        @deepSet key, val, true
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
            if item.val instanceof Itemizer
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
        


appUtilSrvc.value "Itemizer", Itemizer


###
Orderer class  used to provide ordered data object with keyed lookup
Entries can be accessed by key but the order of entry or sort is preserved.

Orderer instances  can by used with Angular 1.15+  ng-repeat track by 
functions to guarantee display order when iterating over object properties
such as
<div ng-repeat="key in orderer.keys "
    ng-model="orderer.data[key]">
    
or if values are objects

<div ng-repeat="value in orderer.values() track by index"
    ng-model="value">

###

class Orderer
    constructor: (stuff, deep) ->
        @data = {} # data object maps keys to values
        @keys = [] # list of keys
        @update(stuff, deep)
        
    get: (key, tag) ->
        if tag
            return @data[key]?[tag]
        else
            return @data[key]
        
    set: (key, val, tag) ->
        if key in @keys
            if tag
                @data[key][tag] = val
            else
                @data[key] = val
        else
            @keys.push key
            if tag
                @data[key] = {}
                @data[key][tag] = val
            else
                @data[key] = val
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
    
    deepSet: (key, val, update) ->
        orderer = @data[key]
        if @_isItemList val
            if not (orderer instanceof Orderer) or not update
                orderer = new Orderer
                @set key, orderer
            for item in val
                orderer.deepSet item.key, item.val, update
        else if angular.isObject(val) and not angular.isArray(val) # not array object
            if not (orderer instanceof Orderer) or not update
                orderer = new Orderer()
                @set key, orderer
            for own k, v of val
               orderer.deepSet k, v, update
        else
            @set key, val
        return @
            
    del: (key, tag) ->
        if key in @keys
            if tag
                delete @data[key].val[tag]
            else
                @keys = (_key for _key in @keys when _key != key)
                delete @data[key]
        return @
    
    clear: () ->
        @data = {}
        @keys = []
        return @
    
    items: (deep) ->
        items = []
        for key in @keys
            if deep and (@data[key] instanceof Orderer)
                items.push (new Item(key, @data[key].items(deep)))
            else
                items.push ( new Item(key, @data[key]))
        return items
        

    values: () ->
        return (@data[key] for key in @keys)
        
    sort: (sorter, deep) ->
        @keys.sort sorter
        if deep
            for key in @keys
                if @data[key] instanceof Orderer
                    @data[key].sort(sorter, deep)
        return @keys
    
    update: (stuff, deep) ->
        if stuff?
            if @_isItemList(stuff)
                for item in stuff
                    if deep
                        @deepSet item.key, item.val, true
                    else
                        @set item.key, item.val
            else if angular.isObject(stuff) and not angular.isArray(stuff) 
                for own key, val of stuff
                    if deep
                        @deepSet key, val, true
                    else
                        @set key, val 
        return @
    
    reload: (stuff, deep) ->
        @clear()
        @update(stuff, deep)
        return @
    
    unorder: () ->  
        data = {}
        for key in @keys
            if @data[key] instanceof Orderer
                data[key] = @data[key].unorder()
            else
                data[key] = @data[key]
        return data
    
    filter: (keys) ->
        for key in @keys
            if key not in keys
                delete @data[key]
        @keys = (_key for _key in @keys when _key in keys)
                
        return @
        


appUtilSrvc.value "Orderer", Orderer

