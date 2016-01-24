app
.controller 'containerLogsCtrl',
['$scope', '$state', 'container',
($scope, $state, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			container && container.startContainerLog()

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
