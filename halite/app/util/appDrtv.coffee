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
way to access the error state of the dynaically generated controls 
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

This directive enables dynamic naming of sub forms in
dyanmic form creation

This works around a problem in the angular form directive that the
form name is a string that is not parsed so it cannot be dynamically
generated. This causes a problem with form validation as there is no
way to access the error state of the subform and its controls without a unique name

Usage:

ss-form-name will set the form name its computed value
and replace it as a subform on the form with name ss-outer-form

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
                #return if !ctrls # do nothing if no ctrls
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
