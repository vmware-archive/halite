describe "ssProgress directive", () ->
  progressBar = null
  $scope = null
  percentage = 10
  beforeEach module 'appDrtv'

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope
    $scope.getPercentage = () ->
      return percentage
    progressBar = $compile('<ss-progress percentage="{{getPercentage()}}"></ss-progress>')($scope)
    $scope.$digest()
    return

  it "has the right parent div", () ->
    expect(progressBar.hasClass('progress')).toBe(true)

  it "has the right progressbar div", () ->
    expect(progressBar.find('div.progress-bar')).toBeDefined()

  it "sets the right progress", () ->
    expect(progressBar.find('div')['0'].style.width).toBe("10%")

  it "sets the right progress on repeated invocations", () ->
    percentage = 2
    $scope.$digest()
    expect(progressBar.find('div')['0'].style.width).toBe("2%")
