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
				if val
					@showActionBar()
				else
					@showActionBar 1000
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

		onMouseMove: ($event) ->
			return if $scope.searchString
			@showActionBar 2000

		showActionBar: (timeout) ->
			$elt = angular.element '.log'
			angular.element($elt).addClass('show')
			$timeout.cancel(@showActionBarHandler) if @showActionBarHandler
			if timeout
				@showActionBarHandler = $timeout ->
					angular.element($elt).removeClass('show')
				, timeout
			return false

		search: (searchString) ->
			return if not $scope.container?.runtime
			return if not $scope.stream
			return if not $scope.container.runtime.docker.container.log
			subject = $scope.container.runtime.docker.container.log[$scope.stream]
			if subject
				regex = new RegExp "^(.*#{searchString}.*)$", "gmi"
				m = subject.match regex
				$scope.searchResult[$scope.stream] = m?.join '\n'

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
