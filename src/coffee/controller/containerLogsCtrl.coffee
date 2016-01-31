app
.controller 'containerLogsCtrl',
['$scope', '$state', '$timeout', 'container',
($scope, $state, $timeout, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			container && container.startContainerLog()
			$scope.searchResult = {}
			$scope.searchString = ""
			$scope.$watch 'searchString', (val) =>
				$timeout.cancel(@timeoutHandle) if @timeoutHandle
				@timeoutHandle = $timeout =>
					@search val
				, 1000
			$scope.$watch 'ctrl.streamIsStderr', (streamIsStderr) =>
				if streamIsStderr
					$scope.stream = 'stderr'
				else
					$scope.stream = 'stdout'
				# Do search on the new stream
				@search $scope.searchString
			@streamIsStderr = false
			$scope.stdoutScrollbarLocked = true
			$scope.stderrScrollbarLocked = true

		search: (searchString) ->
			return if not $scope.container?.runtime?.docker.container.log?[$scope.stream]
			subject = $scope.container.runtime.docker.container.log[$scope.stream]
			regex = new RegExp "^(.*#{searchString}.*)$", "gmi"
			m = subject.match regex
			$scope.searchResult[$scope.stream] = m?.join '\n'

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
