app
.directive 'fileChoose', ->
	
	class Directive

		restrict: 'A'

		scope:
			ngModel: "="

		transclude: 'element'

		link: (scope, element, attrs, controller, transclude) ->
			$transcluded = transclude()
			$input = $('<input>').css({'display': 'none'}).attr('type', 'file')
			element.after $input
			element.after $transcluded

			clickListener = (event) ->
				event.preventDefault()
				$input.trigger 'click'
			$transcluded[0].addEventListener 'click', clickListener

			fileChangeListener = (event) ->
				scope.ngModel = @value
				scope.$apply()
			$input[0].addEventListener 'change', fileChangeListener

		controllerAs: 'ctrl'

	return new Directive()
