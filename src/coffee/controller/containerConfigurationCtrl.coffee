app
.controller 'containerConfigurationCtrl',
['$scope', '$state', 'projectMgr', 'container',
($scope, $state, projectMgr, container) ->

	class Controller

		constructor: ->
			$scope.container = container

			$scope.$watch 'container.variables', (newVal, oldVal) =>
				$scope.container.checkConfiguration()
				if newVal and newVal != oldVal
					@save()
			, true

		save: ->
			projectMgr.save()

	return new Controller()

]
