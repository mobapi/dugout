app
.directive 'log', ->
	
	class Directive

		restrict: 'EA'

		scope:
			ngModel: "="
			ngHighlight: "="
			locked: "="

		template: '<div ng-show="ngModel" class="full-height" ng-scrollbars ng-scrollbars-update="scrollbarUpdate" ng-scrollbars-config="scrollbarConfig">
				<pre ng-bind-html="ngModel | search: ngHighlight : true"></pre>
			</div>
			<div ng-show="!ngModel" class="text-empty">
				<span>
					<i class="fa fa-eye"></i>
					{{"The logs are empty"|translate}}
				</span>
			</div>'

		link:
			pre: (scope, iElement) ->
				scope.$watch 'ngModel', =>
					return if not scope.scrollbarUpdate
					if scope.locked
						setTimeout =>
							scope.scrollbarUpdate 'scrollTo', [ 'bottom', 'left' ]
						, 300
				scope.scrollbarConfig =
					axis: 'xy'
					callbacks:
						onTotalScroll: ->
							if not scope.locked
								scope.locked = true
								# try
								# 	scope.$apply();
			post: (scope, iElement) ->
				iElement.find('pre')[0].addEventListener "mousewheel", (e) ->
					if scope.locked and e.wheelDeltaY > 0
						scope.locked = false
						try
							scope.$apply();
				, false


	return new Directive()
