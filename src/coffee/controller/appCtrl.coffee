app
.controller 'appCtrl',
['$scope',
($scope) ->

	class Controller

		constructor: ->
			$scope.ctrl = @

	return new Controller()

]
