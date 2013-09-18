### 
Useful directives for the SaltStack Web App
Uses 'ss' (short for SaltStack) as the prefix to distinguish from built in 'ng'

###



appDrtv = angular.module "appDrtv", []


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
###


appDrtv.directive 'ss-dropdown-toggle', 
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