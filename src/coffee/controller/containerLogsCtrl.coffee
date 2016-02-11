app
.controller 'containerLogsCtrl',
['$scope', '$state', '$timeout', 'container',
($scope, $state, $timeout, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			# if container
			# 	container.startLog().then ->
			# 		console.log 'log started'
			# 	, (error) ->
			# 		console.dir error

				# , ->
				# 	try
				# 		$scope.$apply()

			$scope.$watch 'searchString', (val) =>
				if val
					@showActionBar()
				else
					@showActionBar 1000
				$timeout.cancel(@timeoutHandle) if @timeoutHandle
			# React to log stream change
			$scope.$watch 'streamIsStderr', (streamIsStderr) =>
				if streamIsStderr
					$scope.stream = 'stderr'
				else
					$scope.stream = 'stdout'
			@streamIsStderr = false
			$scope.stdoutScrollbarLocked = true
			$scope.stderrScrollbarLocked = true

		onMouseMove: ($event) ->
			return if $scope.searchString
			@showActionBar 1000

		showActionBar: (timeout) ->
			$elt = angular.element '.log'
			angular.element($elt).addClass('show')
			$timeout.cancel(@showActionBarHandler) if @showActionBarHandler
			if timeout
				@showActionBarHandler = $timeout ->
					angular.element($elt).removeClass('show')
				, timeout
			return false

		clearLog: ->
			$scope.container.clearLog()

	return new Controller()

]
