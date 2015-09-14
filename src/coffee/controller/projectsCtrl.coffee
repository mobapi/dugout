app
.controller 'projectsCtrl',
['$scope', '$state', 'projectsMgr',
($scope, $state, projectsMgr) ->

	class Controller

		constructor: ->
			$scope.projects = projectsMgr.projects

	return new Controller()

]
