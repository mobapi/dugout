app
.controller 'projectContainerCtrl',
['$scope', '$state', 'project',
($scope, $state, project) ->

	class Controller

		constructor: ->
			$scope.project = project

	return new Controller()

]
