app
.controller 'projectConfigurationCtrl',
['$scope', '$state', 'projectsMgr', 'project',
($scope, $state, projectsMgr, project) ->

	class Controller

		constructor: ->
			$scope.project = project

			$scope.$watch 'project.variables', (newVal, oldVal) =>
				$scope.project.checkConfiguration()
				if newVal and newVal != oldVal
					@save()
			, true

		save: ->
			projectsMgr.save()

	return new Controller()

]
