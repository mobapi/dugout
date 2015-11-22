app
.controller 'containerConfigurationCtrl',
['$scope', '$state', 'containersMgr', 'container',
($scope, $state, containersMgr, container) ->

	class Controller

		constructor: ->
			$scope.container = container

			$scope.$watch 'container.variables', (newVal, oldVal) =>
				$scope.container.checkConfiguration()
				if newVal and newVal != oldVal
					@save()
			, true

		save: ->
			containersMgr.save()

	return new Controller()

]
