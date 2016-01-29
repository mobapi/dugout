app
.controller 'containerLogsCtrl',
['$scope', '$state', 'container',
($scope, $state, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			# container && container.startContainerLog()
			$scope.$watch 'ctrl.stderr', (stderr, oldVal) =>
				if stderr
					$scope.stream = 'stderr'
				else
					$scope.stream = 'stdout'
			$scope.$watch 'container.runtime.docker.container.log["stdout"]', =>
				if @updateScrollbarStdout
					setTimeout =>
						@updateScrollbarStdout 'scrollTo', [ 'bottom', 'left' ]
					, 50
			$scope.$watch 'container.runtime.docker.container.log["stderr"]', =>
				if @updateScrollbarStderr
					setTimeout =>
						@updateScrollbarStderr 'scrollTo', [ 'bottom', 'left' ]
					, 50

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
