app
.controller 'containerLogsCtrl',
['$scope', '$state', 'container',
($scope, $state, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			# container && container.runtime.docker && container.startContainerLog()
			$scope.$watch 'ctrl.stderr', (stderr) =>
				if stderr
					$scope.stream = 'stderr'
				else
					$scope.stream = 'stdout'
			$scope.stdoutScrollbarLocked = true
			$scope.stderrScrollbarLocked = true
			$scope.$watch 'container.runtime.docker.container.log["stdout"]', =>
				return if not @stdoutScrollbarUpdate
				if $scope.stdoutScrollbarLocked
					setTimeout =>
						@stdoutScrollbarUpdate 'scrollTo', [ 'bottom', 'left' ]
					, 50
			$scope.$watch 'container.runtime.docker.container.log["stderr"]', =>
				return if not @stdoutScrollbarUpdate
				if $scope.stderrScrollbarLocked
					setTimeout =>
						@stderrScrollbarUpdate 'scrollTo', [ 'bottom', 'left' ]
					, 50

			angular.element('.log .stdout pre')[0].addEventListener "mousewheel", @stdoutMouseScroll, false
			angular.element('.log .stderr pre')[0].addEventListener "mousewheel", @stderrMouseScroll, false

		stdoutMouseScroll: (e) ->
			if $scope.stdoutScrollbarLocked and e.wheelDeltaY > 0
				$scope.stdoutScrollbarLocked = false
				try
					$scope.$apply();

		stderrMouseScroll: (e) ->
			if $scope.stderrScrollbarLocked and e.wheelDeltaY > 0
				$scope.stderrScrollbarLocked = false
				try
					$scope.$apply();

		stdoutScrollbarConfig: ->
			return {
				axis: 'xy'
				callbacks:
					onTotalScroll: ->
						if not $scope.stdoutScrollbarLocked
							$scope.stdoutScrollbarLocked = true
							try
								$scope.$apply();
			}

		stderrScrollbarConfig: ->
			return {
				axis: 'xy'
				callbacks:
					onTotalScroll: ->
						if not $scope.stderrScrollbarLocked
							$scope.stderrScrollbarLocked = true
							try
								$scope.$apply();
			}

		clearLog: ->
			$scope.container.clearContainerLog()

	return new Controller()

]
