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
			# Do search when logs are updated
			$scope.$watch 'container.runtime.docker.container.log["stdout"]', =>
				@search $scope.searchString
			$scope.$watch 'container.runtime.docker.container.log["stderr"]', =>
				@search $scope.searchString
			# Do search when search string is modified
			$scope.$watch 'searchString', (val) =>
				$timeout.cancel(@timeoutHandle) if @timeoutHandle
				@timeoutHandle = $timeout =>
					@search val
				, 1000
			# React to log stream change
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
			return if not $scope.container?.runtime
			subject = $scope.container.runtime.docker.container.log[$scope.stream]
			regex = new RegExp "^(.*#{searchString}.*)$", "gmi"
			m = subject.match regex
			$scope.searchResult[$scope.stream] = m?.join '\n'

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
