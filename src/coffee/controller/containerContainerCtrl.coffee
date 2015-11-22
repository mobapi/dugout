app
.controller 'containerContainerCtrl',
['$scope', '$state', 'container',
($scope, $state, container) ->

	class Controller

		constructor: ->
			$scope.container = container

	return new Controller()

]
