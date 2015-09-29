app
.controller 'projectLogsCtrl',
['$scope', '$state', 'project',
($scope, $state, project) ->

	class Controller

		constructor: ->
			$scope.project = project
			project.startContainerLog()

	return new Controller()

]
