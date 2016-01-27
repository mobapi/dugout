app
.controller 'containerLogsCtrl',
['$scope', '$state', 'container',
($scope, $state, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			container && container.startContainerLog()
			$scope.$watch 'ctrl.stderr', (stderr, oldVal) =>
				if stderr
					$scope.stream = 'stderr'
				else
					$scope.stream = 'stdout'

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
