###
Generic app utility services

OrdereMap service return new instance of OMap

###


appUtilSrvc = angular.module("appUtilSrvc", [])

class ArgInfo
    constructor: (@value, @required, @placeholder = 'Enter Input') ->

appUtilSrvc.value "ArgInfo", ArgInfo
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

Angular 1.15+ provides the ng-repeat
which means one does not need the itemizations for ng-repeating but angular sort
only works on arrays to need items list for that. Also angular filter string will
work on nested itemizers but not itemizer with not itemizer values.
###

class Itemizer
    constructor: (stuff, deep) ->
        @_data = {} # data object maps keys to values that are item objects
        @_keys = [] # list of keys
        @update(stuff, deep)
        return @

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
        if not sorter?
            return @_keys
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


class Minioner
    constructor: (@id) ->
        @active = false
        @grains = new Itemizer()
        @jobs = new Itemizer()
        @events = new Itemizer()
        return @

    activize: () ->
        @active = true
        return @

    deactivize: () ->
        @active = false
        return @

    grainize: (grains, update) ->
        @grains.deepSet(grains, update)
        return @

    unlinkJobs: () ->
        for job in @jobs.values()
            job.minions.del(@id)
        @jobs.clear()
        return @

    processEvent: (edata) ->
        @events.set(edata.tag, edata)
        return @

appUtilSrvc.value "Minioner", Minioner

class Resulter
    constructor: (@id) ->
        @reset()
        return @

    reset: () ->
        @active = null
        @done = false
        @fail = true
        @error = ''
        @success = false
        @return = null
        @retcode = null
        return @

    mode:  () ->
        unless @return? or @error
            return ''
        if @error
            return 'error'
        return 'return'

    results:  () ->
        unless @return? or @error
            return []
        if @error
            return [@error]
        return [@return]

appUtilSrvc.value "Resulter", Resulter

class Jobber
    @STATUS_SUCCESS = 'success'
    @STATUS_FAILURE = 'danger'
    @STATUS_INFO = 'info'

    constructor: (@jid, @cmd, mids=[]) ->
        @name = @humanize(@cmd)
        @fail = true
        @errors = []
        @done = false
        @defer = null
        @promise = null
        @events = new Itemizer()
        @results = new Itemizer()
        @minions = new Itemizer()
        @progressEvents = new Itemizer()
        @resolveOnAnyPass = false
        @totalEvents = 0
        @completedEvents = 0
        @eventInfo = new Itemizer()
        for mid in mids
            @results.set(mid, new Resulter(mid))
        return @

    commit: ($q) ->  #return promise if already exists otherwise create and return
        unless @defer?
            @defer = $q.defer()
            @promise = @defer.promise
        return @promise

    initResults: (mids=[]) ->
        for mid in mids
          unless @results.get(mid)?
            @results.set(mid, new Resulter(mid))
        return @

    humanize: (cmd) ->
        unless cmd
            cmd = @cmd
        return ((part for part in [cmd.fun, cmd.tgt].concat(cmd.arg) \
                    when part? and part isnt '').join(' ').trim())

    checkDone: () ->
        # active is true or null ie not false
        @done = _((result.done for result in @results.values() when\
            result.active isnt false)).all()
        if not @done
          anyDone = _((result.done for result in @results.values() when result.active isnt false)).any()
          @defer.resolve @ if @resolveOnAnyPass and anyDone
          return false

        @fail = _((result.fail for result in @results.values() when\
            result.active and result.done )).any()

        #console.log "Job Done. Fail = #{@fail}"
        #console.log @

        if @errors.length > 0
            @defer?.reject @errors
        else
            @defer?.resolve @

        @defer = null
        @promise = null
        return true

    linkMinion: (minion) ->
        minion.jobs.set(@jid, @)
        @minions.set(minion.id, minion)
        return @

    unlinkMinion: (mid) ->
        minion = @minions.get(mid)
        @minions.del(mid)
        minion?.get('jobs').del(@jid)
        return @

    processEvent: (edata) ->
        @events.set(edata.tag, edata)
        return @

    processNewEvent: (data) ->
        #console.log "Job New Event"
        @initResults(data.minions)
        @cmd =
            mode: 'async'
            fun: data.fun
            tgt: data.tgt
            arg: data.arg
        return @

    processRetEvent: (data) ->
        #console.log "Job Ret Event"
        mid = data.id
        unless @results.get(mid)?
            @results.set(mid, new Resulter(mid))
        result = @results.get(mid)

        result['done'] = true
        result['active'] = true
        result['success'] = data.success
        if data.success == true
            result['retcode'] = data.retcode
        if data.success == true
            if data.retcode == 0
                result['return'] = data.return
                result['fail'] = false
            else
                result['error'] = "Error retcode = #{data.retcode}"
                @errors.push(result['error'])
        else
            result['error'] = data.return
            @errors.push(result['error'])
        return @

    totalProgEvents: (mid) ->
      return @getLatestProgEvent(mid).numEvents

    getCurrentRunNumber: (mid) ->
      return @getLatestProgEvent(mid).runNum

    getLatestProgEvent: (mid) ->
      progEvents = @progressEvents.get(mid)
      return progEvents[progEvents.length - 1]

    getLatestComment: (mid) ->
      return @getLatestProgEvent(mid).comment

    getPercentageComplete: (mid) ->
      return Math.round(@getCurrentRunNumber(mid) / @totalProgEvents(mid) * 100)

    hasProgressEvents: (mid) ->
      if @progressEvents.get(mid)?
        return true
      else
        return false

    currentState: (mid) ->
      return @getLatestProgEvent(mid).state

    hasNestedProgressEvents: () ->
      if @progressEvents.keys().length == 0
        return false
      else
        return true

    totalPercentageComplete: () ->
      return Math.round(@completedEvents / @totalEvents * 100)

    updateProgessEventInfo: (mid, runNum) ->
      @eventInfo.set(mid, runNum)
      @completedEvents = _.reduce @eventInfo.values(), (memo, num) ->
        memo + num
      , 0
      return true

    processProgEvent: (edata) ->
      data = edata.data
      mid = data.id
      hasChanges = true
      unless @progressEvents.get(mid)
        @progressEvents.set(mid, [])
      results = @progressEvents.get(mid)
      eventInfo = data.data
      runNum = eventInfo.ret.__run_num__ + 1
      result = new Resulter(runNum)
      result['mid'] = mid
      result['numEvents'] = eventInfo.len
      result['runNum'] = runNum
      result['comment'] = eventInfo.ret.comment
      result['done'] = true
      result['active'] = true
      result['success'] = eventInfo.ret.result

      hasChanges = false if not eventInfo.ret.changes.diff?
      if not result['success']
        result['state'] = Jobber.STATUS_FAILURE
      else
        if hasChanges
          result['state'] = Jobber.STATUS_INFO
        else
          result['state'] = Jobber.STATUS_SUCCESS

      results.push(result)

      @totalEvents = @minions.keys().length * result['numEvents']
      @updateProgessEventInfo(mid, result['runNum'])
      return @

appUtilSrvc.value "Jobber", Jobber

class Bosser extends Jobber
    constructor: (@jid, @cmd) ->
        super(jid, cmd, ['master']) #one result with id 'master'
        return @

    processNewEvent: (data) ->
        # console.log "Run/Wheel New Event"
        # console.log data

        @initResults(data.minions)
        @cmd =
            mode: 'async'
            fun: data.fun
        if data.tgt
            @cmd['tgt'] = data.tgt
        if data.arg
            @cmd['arg'] = data.arg
        return @

    processRetEvent: (data) ->
        # console.log "Run/Wheel Ret Event"
        # console.log data

        result = @results.get('master')
        result.done = true
        @done = true
        result.success = data.success
        result.fail = ! result.success
        @fail = result.fail

        if result.success == true
            result.return = data.return
        else
            result.error = data.return
            @errors.push(data.return)

        # console.log "Run/Wheel Done. Fail = #{@fail}"
        # console.log @

        if @errors.length > 0
            @defer?.reject(@errors)
        else
            @defer?.resolve(@)
        @defer = null
        @promise = null
        return @

class Runner extends Bosser
appUtilSrvc.value "Runner", Runner

class Wheeler extends Bosser
appUtilSrvc.value "Wheeler", Wheeler

class Commander
    constructor: (@name, @cmds) ->
        @jobs = new Itemizer()
        return @

appUtilSrvc.value "Commander", Commander


###
Pagerage class used to manage pagination control form


###

class Pagerage
    constructor: (@itemCount=0, @pagerLimit=5, @perPage=20, @page=1) ->
        return @

    itemOffset: () ->
        return (Math.max(@page-1,0) * @perPage)

    setPage: (page) ->
        @page = page;
        return @

    displayPage: (page) ->
        # console.log "Display page " + page
        return @

appUtilSrvc.value "Pagerage", Pagerage
