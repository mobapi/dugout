app
.controller 'containerLogsCtrl',
['$scope', '$state', 'container',
($scope, $state, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			container && container.startContainerLog()
			$scope.searchString = ""
			$scope.$watch 'searchString', (val) =>
				@search val
			$scope.$watch 'ctrl.stderr', (stderr) =>
				if stderr
					$scope.stream = 'stderr'
				else
					$scope.stream = 'stdout'
			@stderr = false
			$scope.stdoutScrollbarLocked = true
			$scope.stderrScrollbarLocked = true

		search: (searchString) ->
			return if not $scope.container?.runtime?.docker.container.log?[$scope.stream]
			subject = $scope.container.runtime.docker.container.log[$scope.stream]
			regex = new RegExp "^(.*#{searchString}.*)$", "gmi"
			m = subject.match regex
			console.dir m

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
