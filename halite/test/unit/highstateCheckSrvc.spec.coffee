describe "Highstate Check Service Unit Tests", () ->

  HighstateCheck = null
  Item = null
  Resulter = null
  minions = null
  jobs = null
  AppData = null
  Minioner = null

  _stateData = '{"file_|-/tmp/testfile4_|-/tmp/testfile4_|-managed": {"comment":"The file /tmp/testfile4 is in the correct state","__run_num__":3,"changes":{},"name":"/tmp/testfile4","result":true},"file_|-somefile2_|-/tmp/testfile6_|-managed":{"comment":"The file /tmp/testfile6 is in the correct state","__run_num__":5,"changes":{},"name":"/tmp/testfile6","result":true}}'
  _dirtyStateData = '{"file_|-/tmp/testfile1_|-/tmp/testfile1_|-managed":{"comment":"The following values are set to be changed:newfile: /tmp/testfile1","__run_num__":0,"changes":{},"name":"/tmp/testfile1","result":null}}'
  _multipleDirtyStateData = '{"file_|-/tmp/testfile1_|-/tmp/testfile1_|-managed":{"comment":"The following values are set to be changed:newfile: /tmp/testfile1","__run_num__":0,"changes":{},"name":"/tmp/testfile1","result":null}, "file_|-/tmp/testfile4_|-/tmp/testfile4_|-managed":{"comment":"The following values are set to be changed:newfile: /tmp/testfile4","__run_num__":4,"changes":{},"name":"/tmp/testfile4","result":null}}'

  beforeEach module "MainApp"

  beforeEach inject (_HighstateCheck_, _Item_, _Resulter_, _AppData_, _Minioner_) ->
    Item = _Item_
    Resulter = _Resulter_
    HighstateCheck = _HighstateCheck_
    AppData = _AppData_
    Minioner = _Minioner_
    return


  it 'Gets no comments when there are no changes', () ->
    expect(HighstateCheck.highstateDirtyComments(JSON.parse(_stateData)).length).toBe(0)


  it 'Gets the right comments when there are changes', () ->
    expect(HighstateCheck.highstateDirtyComments(JSON.parse(_dirtyStateData))[0]).toBe("The following values are set to be changed:newfile: /tmp/testfile1")

  it 'Gets the right comments when there are multiple changes', () ->
    changes = [
      "The following values are set to be changed:newfile: /tmp/testfile1",
      "The following values are set to be changed:newfile: /tmp/testfile4"
    ]

    expect(HighstateCheck.highstateDirtyComments(JSON.parse(_multipleDirtyStateData)).join(',')).toBe(changes.join(','))

  it 'Applies correct status to minions whose highstate is not consistent', () ->
    result1 = new Resulter('A')
    result1.return = JSON.parse(_dirtyStateData)
    item1 = new Item('A', result1)

    if !AppData.get('minions')?
      AppData.set('minions', new Itemizer())
    minions = AppData.get('minions')
    minions.set('A', new Minioner('A'))
    minions.set('B', new Minioner('B'))

    result2 = new Resulter('B')
    result2.return = JSON.parse(_stateData)
    item2 = new Item('B', result2)
    items = [item1, item2]

    HighstateCheck.processHighstateCheckReturns(items)

    expect(minions.get('A').highstateStatus.dirty).toBe(true)

  it 'Does not apply dirty status to minion with consistent highstate', () ->
    result1 = new Resulter('A')
    result1.return = JSON.parse(_dirtyStateData)
    item1 = new Item('A', result1)

    if !AppData.get('minions')?
      AppData.set('minions', new Itemizer())
    minions = AppData.get('minions')
    minions.set('A', new Minioner('A'))
    minions.set('B', new Minioner('B'))

    result2 = new Resulter('B')
    result2.return = JSON.parse(_stateData)
    item2 = new Item('B', result2)
    items = [item1, item2]

    HighstateCheck.processHighstateCheckReturns(items)

    expect(minions.get('B').highstateStatus.dirty).toBe(false)
