### 
Useful directives for the SaltStack Web App
Uses 'ss' (short for SaltStack) as the prefix to distinguish from built in 'ng'

###



appDrtv = angular.module "appDrtv", []


appDrtv.directive 'ssInputName',
    [ '$interpolate', ($interpolate) ->
        ddo =
            restrict: 'A' # only activate on element attribute
            require: ['?ngModel', '^?form']
            link: ($scope, elm, attrs, ctrls)->
                #return if !ctrls # do nothing if no ctrls
                ex = $interpolate(elm.attr(attrs.$attr.ssInputName));
                nameTransformed = ex($scope)
                modelCtrl = ctrls[0]
                modelCtrl.$name = nameTransformed
                elm.attr("name",nameTransformed)
                formCtrl = ctrls[1]
                formCtrl.$addControl(modelCtrl)
                return true
        return ddo
    ]


###
Workaround so that model values are updated after autofill.
Please look at https://github.com/angular/angular.js/issues/1460 for
more details.
###
appDrtv.directive "ssAutofillWorkaround", ["$timeout", ($timeout)->
  ddo =
    restrict: 'A'
    require: 'ngModel'
    link: (scope, attrs, element, modelController) ->
      $timeout () ->
        preFilledValue = element.$$element[0].value
        modelController.$setViewValue(preFilledValue) if modelController.$pristine and preFilledValue? and preFilledValue != ''
      , 1000
      return
  return ddo
]


# Add custom progress bar since
# Angular UI is not yet ported to Twitter Bootstrap 3
appDrtv.directive("ssProgress", ->
  ddo =
    restrict: 'E'
    replace: true
    templateUrl: "app/util/template/progressbar/ss_progress.html"
    scope:
      percentage: '@'
  return ddo
)


###
ss-input-name  ssInputName

This directive enables dynamic naming of form input controls 
to allow dyanmic form creation

This works around a problem in the angular control directives that the
control name is a string that is not parsed so it cannot be dynamically
generated. This causes a problem with form validation as there is no
way to access the error state of the dynamically generated controls 
without unique names

Usage:

ss-input-name will set the input control name to its computed value

Example:

$scope.users = [ "John", "Mary"]

<form>
    <div ng-repeat="user in users">
        <input type="text" ss-input-name="user{{$index}}" ng-model="users[$index]">
    </div>
</form>
###

appDrtv.directive 'ssInputName', 
    [ '$interpolate', ($interpolate) ->
        ddo = 
            restrict: 'A' # only activate on element attribute
            require: ['?ngModel', '^?form'] 
            link: ($scope, elm, attrs, ctrls)->
                #return if !ctrls # do nothing if no ctrls
                ex = $interpolate(elm.attr(attrs.$attr.ssInputName));
                nameTransformed = ex($scope)
                modelCtrl = ctrls[0]
                modelCtrl.$name = nameTransformed
                elm.attr("name",nameTransformed)
                formCtrl = ctrls[1]
                formCtrl.$addControl(modelCtrl)
                return true
        return ddo        
    ]

###
ss-form-name ssFormName
ss-outer-form ssOuterForm

This directive enables dynamic naming of sub forms in dynamic form creation

This works around a problem in the angular form directive that the
form name is a string that is not parsed so it cannot be dynamically
generated. This causes a problem with form validation as there is no
way to access the error state of the subform and its controls without a unique name

Usage:

ss-form-name will set the form name to its computed value
and replace it as a subform on the form with name given by ss-outer-form

Example:
$scope.users = 
[
    first: "John"
    last: "Smith"
,
    first: "Mary"
    last: "Martin"

]
<form name="orderForm">
    <div ng-repeat="user in users">
        <ng-form ss-form-name="userForm{{$index}}" ss-outer-form="orderForm" >
            <input type="text" name="first" placeholder="First" ng-model="user.first" >
            <input type="text" name="last" placeholder="Last"  ng-model="user.last" >
        </ng-form>
    </div
</div>

<input ss-input-name="


###

appDrtv.directive 'ssFormName', 
    [ '$interpolate', ($interpolate) ->
        ddo = 
            restrict: 'A' # only activate on element attribute
            require: '?form' 
            link: ($scope, elm, attrs, ctrl)->
                #return if !ctrl # do nothing if no ctrl 
                ex = $interpolate(elm.attr(attrs.$attr.ssFormName));
                innerFormName = ex($scope)
                innerFormCtrl = ctrl
                formCtrl = $scope.$parent[elm.attr(attrs.$attr.ssOuterForm)]
                formCtrl.$removeControl(innerFormCtrl)
                innerFormCtrl.$name = innerFormName
                elm.attr("name",innerFormName)
                formCtrl.$addControl(innerFormCtrl)
                return true
        return ddo        
    ]


###
ss-toggle-union ssToggleUnion

Button control that only allows either none or only one of group of buttons 
to be active at a time. 

A click on any inactive button toggles it active and also makes inactive any
other btn in the group that may be active. Another click on the same btn
toggles it inactive. 

Suppose for example there are three buttons in the group. The states of the group
can be:
   No buttons active
   One and only one of the buttons active

This is different from a radio button group where one of the buttons in the group
is always active.

Usage:


Upon click when control element's class includes 'active'
    The control element's class has 'active' removed ie toggled off
    The control element's associated ngModel property is set to the value given by 
    its ss-toggle-union attribute

Upon click when control element's class does not include 'active'
    The control element's class has 'active' added ie toggled on
    The control element's associated ngModel property is set to null


Any other elements in the same scope that share the same ngModel property 
will be made inactive because their render function checks the ngModel property
to see if it matches the element's associated ss-toggle-union attribute value
and if not removes 'active' from the elements class


Example:

$scope.toggleModel = 'Middle';

h4>Toggle Union</h4>
<pre>{{toggleModel}}</pre>
<div class="btn-group">
    <button type="button" class="btn btn-primary" ng-model="toggleModel" 
        ss-toggle-union="'Left'">Left</button>
    <button type="button" class="btn btn-primary" ng-model="toggleModel" 
        ss-toggle-union="'Middle'">Middle</button>
    <button type="button" class="btn btn-primary" ng-model="toggleModel" 
        ss-toggle-union="'Right'">Right</button>
</div>


###



appDrtv.constant 'toggleUnionConfig',
  activeClass: 'active'
  toggleEvent: 'click'


appDrtv.directive 'ssToggleUnion', 
    [ 'toggleUnionConfig', (toggleUnionConfig) ->
        activeClass = toggleUnionConfig.activeClass || 'active'
        toggleEvent = toggleUnionConfig.toggleEvent || 'click'
        
        ddo =
            restrict: 'A' # only activate on element attribute
            require: 'ngModel'
            link: ($scope, elm, attrs, ctrl) ->
                # ctrl should be ngModelController
                ### Model to View  ###
                ctrl.$render = () ->
                    elm.toggleClass( activeClass, 
                        angular.equals(ctrl.$modelValue, 
                            $scope.$eval(attrs.ssToggleUnion)))
                    return true
                
                ### View to Model ###
                elm.bind toggleEvent, () ->
                    if !elm.hasClass(activeClass)
                        $scope.$apply () ->
                            ctrl.$setViewValue $scope.$eval(attrs.ssToggleUnion)
                            ctrl.$render()
                            return true 
                    else
                        $scope.$apply () ->
                            ctrl.$setViewValue null
                            ctrl.$render()
                            return true 
                    
                return true
        
        return ddo
    ]


###
ss-dropdown-toggle ssDropDownToggle
Dropdown toggle
Eventually replace this with ui-bootstrap when it reaches the 0.7 release
which will be bootstrap 3 compatible

Apparently the way it works is that a click toggles on the class "open"
on the parent element of the dropdown-toggle element.
Via css this results in the sibling element with class "dropdown-menu" 
becoming visible.

Also the click binds to the click the closeMenu function
So a click on a menu item propagates upto the click for closemenu
and then is not propagated further.

  <li class="dropdown">
    <a class="dropdown-toggle">My Dropdown Menu</a>
    <ul class="dropdown-menu">
      <li ng-repeat="choice in dropChoices">
        <a ng-href="{{choice.href}}">{{choice.text}}</a>
      </li>
    </ul>
  </li>
  
<div class="dropdown">
  <button class="btn ss-dropdown-toggle">Action<b class="caret"></b></button>
  <ul class="dropdown-menu">
    <li class="nav-header">State</li>
    <li><a ng-href="">Hi</a></li>
    <li class="divider"></li>
    <li class="nav-header">Test</li>
    <li><a ng-href="">Bye</a></li>
  </ul>
</div>


###


appDrtv.directive 'ssDropdownToggle', 
    ['$document', '$location', ($document, $location) ->
        openElement = null
        closeMenu = angular.noop
        ddo =
            restrict: 'CA',
            link: ($scope, elm, attrs) ->
                $scope.$watch '$location.path', () -> closeMenu()
                    
                elm.parent().bind 'click', () -> closeMenu()
                elm.bind 'click', (event) ->
                    elementWasOpen = (elm == openElement)
                    event.preventDefault()
                    event.stopPropagation()
          
                    if !!openElement then closeMenu()
          
                    if !elementWasOpen
                        elm.parent().addClass('open');
                        openElement = elm;
                        
                        closeMenu = (event) ->
                            if event
                                event.preventDefault()
                                event.stopPropagation()
                            
                            $document.unbind 'click', closeMenu
                            elm.parent().removeClass 'open'
                            closeMenu = angular.noop
                            openElement = null
                            return true
                            
                        $document.bind 'click', closeMenu
                    return true
                    
                return true
                
        return ddo
    ]


###
ss-alert ssAlert

Replacement for ui-bootstrap alert


<ss-alert type="'error'" close="closeAlert()" ng-cloak 
      ng-show="!!$parent.errorMsg">Error! {{errorMsg}}
</ss-alert>

<ss-alert ng-repeat="alert in alerts" type="alert.type" 
    close="closeAlert($index)">{{alert.msg}}</ss-alert>

Directive templates replace the directive element.
###

appDrtv.directive 'ssAlert', () ->
    ddo =
        restrict: 'EA'
        templateUrl:'template/alert/ss_alert.html'
        transclude: true
        replace: true
        scope: 
            type: '=',
            close: '&'
        link: ($scope, elm, attrs, ctlr) ->
            $scope.closeable = attrs.close?;
            return true
    
    return ddo




###
ss-pagination ssPagination Directive

replacement for UI-bootstrap pagination

<ss-pagination 
    class="pagination-sm tight"
    page="currentPage" 
    total-items="totalItems" 
    items-per-page="itemsPerPage"
    max-size="maxSize"
    on-select-page="displayPage(page)"
    num-pages
    direction-links="true"
    previous-text="&lsaquo;" 
    next-text="&rsaquo;" 
    boundary-links="true" 
    first-text="&laquo;" 
    last-text="&raquo;">
</ss-pagination>

$scope.totalItems = 64
$scope.currentPage = 1
$scope.maxSize = 5
$scope.itemsPerPage = 10

$scope.setPage = (pageNo) ->
    $scope.currentPage = pageNo;
    
$scope.displayPage = (pageNo) ->
    $scope.stuff = "info from page" + pageNo



Pagination Settings attributes of ssPagination element

Settings can be provided as attributes in the <pagination> or 
globally configured through the paginationConfig.

page  : Current page number. First page is 1.
total-items  : Total number of items in all pages.
items-per-page  (Defaults: 10) : Maximum number of items per page. 
        A value less than one indicates all items on one page.
on-select-page (page) (Default: null) : An optional expression called when a 
    page is selected having the page number as argument.
max-size  (Defaults: null) : Limit number of page buttons to display for pagination size.
num-pages readonly : Total number of pages to display.
rotate (Defaults: true) : Whether to keep current page in the middle of the visible ones.

direction-links (Default: true) : Whether to display Previous / Next buttons.
previous-text (Default: 'Previous') : Text for Previous button.
next-text (Default: 'Next') : Text for Next button.

boundary-links (Default: false) : Whether to display First / Last buttons.
first-text (Default: 'First') : Text for First button.
last-text (Default: 'Last') : Text for Last button.


###


appDrtv.controller("PaginationController", ["$scope", "$attrs", "$parse", "$interpolate", 
($scope, $attrs, $parse, $interpolate) ->
    self = this
    @init = (defaultItemsPerPage) ->
        if $attrs.itemsPerPage
            $scope.$parent.$watch $parse($attrs.itemsPerPage), (value) ->
                self.itemsPerPage = parseInt(value, 10)
                $scope.totalPages = self.calculateTotalPages()
    
        else
             @itemsPerPage = defaultItemsPerPage
  
    @noPrevious = ->
        @page is 1
  
    @noNext = ->
        @page is $scope.totalPages
  
    @isActive = (page) ->
        @page is page
  
    @calculateTotalPages = ->
        (if @itemsPerPage < 1 then 1 else Math.ceil($scope.totalItems / @itemsPerPage))
  
    @getAttributeValue = (attribute, defaultValue, interpolate) ->
        (if angular.isDefined(attribute) then (
            (if interpolate then $interpolate(attribute)($scope.$parent) 
            else $scope.$parent.$eval(attribute))) 
        else defaultValue)
  
    @render = ->
        @page = parseInt($scope.page, 10) or 1
        $scope.pages = @getPages(@page, $scope.totalPages)
  
    $scope.selectPage = (page) ->
        if not self.isActive(page) and page > 0 and page <= $scope.totalPages
            $scope.page = page
            $scope.onSelectPage page: page
    
    $scope.$watch "totalItems", ->
        $scope.totalPages = self.calculateTotalPages()
  
    $scope.$watch "totalPages", (value) ->
        $scope.numPages = value  if $attrs.numPages
        if self.page > value
            $scope.selectPage value
        else
            self.render()
  
    $scope.$watch "page", ->
        self.render()
    
    return true
])

appDrtv.constant("paginationConfig",
    itemsPerPage: 10
    boundaryLinks: false
    directionLinks: true
    firstText: "First"
    previousText: "Previous"
    nextText: "Next"
    lastText: "Last"
    rotate: true
)

appDrtv.directive "ssPagination", ["$parse", "paginationConfig", ($parse, config) ->
    restrict: "EA"
    scope:
        page: "="
        totalItems: "="
        onSelectPage: " &"
        numPages: "="

    controller: "PaginationController"
    templateUrl: "template/pagination/ss_pagination.html"
    replace: true
    link: (scope, element, attrs, paginationCtrl) ->
        # Setup configuration parameters
        # Create page object used in template
        makePage = (number, text, isActive, isDisabled) ->
            number: number
            text: text
            active: isActive
            disabled: isDisabled
        maxSize = undefined
        boundaryLinks = paginationCtrl.getAttributeValue(attrs.boundaryLinks, config.boundaryLinks)
        directionLinks = paginationCtrl.getAttributeValue(attrs.directionLinks, config.directionLinks)
        firstText = paginationCtrl.getAttributeValue(attrs.firstText, config.firstText, true)
        previousText = paginationCtrl.getAttributeValue(attrs.previousText, config.previousText, true)
        nextText = paginationCtrl.getAttributeValue(attrs.nextText, config.nextText, true)
        lastText = paginationCtrl.getAttributeValue(attrs.lastText, config.lastText, true)
        rotate = paginationCtrl.getAttributeValue(attrs.rotate, config.rotate)
        paginationCtrl.init config.itemsPerPage
        if attrs.maxSize
            scope.$parent.$watch $parse(attrs.maxSize), (value) ->
                maxSize = parseInt(value, 10)
                paginationCtrl.render()
    
        paginationCtrl.getPages = (currentPage, totalPages) ->
            pages = []
            
            # Default page limits
            startPage = 1
            endPage = totalPages
            isMaxSized = (angular.isDefined(maxSize) and maxSize < totalPages)
            
            # recompute if maxSize
            if isMaxSized
                if rotate
                    # Current page is displayed in the middle of the visible ones
                    startPage = Math.max(currentPage - Math.floor(maxSize / 2), 1)
                    endPage = startPage + maxSize - 1
                    
                    # Adjust if limit is exceeded
                    if endPage > totalPages
                        endPage = totalPages
                        startPage = endPage - maxSize + 1
                else
                    # Visible pages are paginated with maxSize
                    startPage = ((Math.ceil(currentPage / maxSize) - 1) * maxSize) + 1
                    
                    # Adjust last page if limit is exceeded
                    endPage = Math.min(startPage + maxSize - 1, totalPages)
            
            # Add page number links
            number = startPage
    
            while number <= endPage
                page = makePage(number, number, paginationCtrl.isActive(number), false)
                pages.push page
                number++
            
            # Add links to move between page sets
            if isMaxSized and not rotate
                if startPage > 1
                    previousPageSet = makePage(startPage - 1, "...", false, false)
                    pages.unshift previousPageSet
                if endPage < totalPages
                    nextPageSet = makePage(endPage + 1, "...", false, false)
                    pages.push nextPageSet
            
            # Add previous & next links
            if directionLinks
                previousPage = makePage(currentPage - 1, previousText, false, paginationCtrl.noPrevious())
                pages.unshift previousPage
                nextPage = makePage(currentPage + 1, nextText, false, paginationCtrl.noNext())
                pages.push nextPage
            
            # Add first & last links
            if boundaryLinks
                firstPage = makePage(1, firstText, false, paginationCtrl.noPrevious())
                pages.unshift firstPage
                lastPage = makePage(totalPages, lastText, false, paginationCtrl.noNext())
                pages.push lastPage
            pages
]

###
ss-pager ssPager

Replacement for UI-Bootstrap pager directive

Settings can be provided as attributes in the <ss-pager> or globally configured 
through the pagerConfig. 

page  : Current page number. First page is 1.
total-items  : Total number of items in all pages.
items-per-page  (Defaults: 10) : Maximum number of items per page. 
        A value less than one indicates all items on one page.
on-select-page (page) (Default: null) : An optional expression called when a 
    page is selected having the page number as argument. 

Other settings are:

align (Default: true) : Whether to align each link to the sides.
previous-text (Default: '« Previous') : Text for Previous button.
next-text (Default: 'Next »') : Text for Next button.

<ss-pager total-items="totalItems" page="currentPage"></ss-pager>

###

appDrtv.constant "pagerConfig",
    itemsPerPage: 10
    previousText: "« Previous"
    nextText: "Next »"
    align: true

appDrtv.directive "ssPager", ["pagerConfig", (config) ->
    restrict: "EA"
    scope:
        page: "="
        totalItems: "="
        onSelectPage: " &"
        numPages: "="
  
    controller: "PaginationController"
    templateUrl: "template/pagination/pager.html"
    replace: true
    link: (scope, element, attrs, paginationCtrl) ->
      
      # Setup configuration parameters
      
      # Create page object used in template
      makePage = (number, text, isDisabled, isPrevious, isNext) ->
            number: number
            text: text
            disabled: isDisabled
            previous: (align and isPrevious)
            next: (align and isNext)
      previousText = paginationCtrl.getAttributeValue(attrs.previousText, config.previousText, true)
      nextText = paginationCtrl.getAttributeValue(attrs.nextText, config.nextText, true)
      align = paginationCtrl.getAttributeValue(attrs.align, config.align)
      paginationCtrl.init config.itemsPerPage
      paginationCtrl.getPages = (currentPage) ->
        [makePage(currentPage - 1, previousText, paginationCtrl.noPrevious(), true, false), 
            makePage(currentPage + 1, nextText, paginationCtrl.noNext(), false, true)]
]


appDrtv.run ["$templateCache", ($templateCache) ->
    $templateCache.put( "template/alert/ss_alert.html",
    """
<div class="alert" ng-class="'alert-' + (type || 'warning')">
    <button ng-show="closeable" type="button" class="close" ng-click="close()">&times;</button>
    <div ng-transclude></div>
</div>
    """
    )
    
    $templateCache.put( "template/pagination/ss_pagination.html",
    """
<ul class="pagination">
  <li ng-repeat="page in pages" ng-class="{active: page.active, disabled: page.disabled}"><a ng-click="selectPage(page.number)">{{page.text}}</a></li>
</ul>
    """
    )
    
    $templateCache.put( "template/pagination/ss_pager.html",
    """
<ul class="pager">
    <li ng-repeat="page in pages" ng-class="{disabled: page.disabled, previous: page.previous, next: page.next}"><a ng-click="selectPage(page.number)">{{page.text}}</a></li>
</ul>
    """
    )

    $templateCache.put( "app/util/template/progressbar/ss_progress.html",
    """
<div class="progress">
  <div class="progress-bar"  role="progressbar" aria-valuenow="{{percentage}}" aria-valuemin="0" aria-valuemax="100" style="width: {{percentage}}%">
    <span class="sr-only">{{percentage}}% Complete</span>
  </div>
</div>
    """
    )
]

