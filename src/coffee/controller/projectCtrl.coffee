app
.controller 'projectCtrl',
['$scope', 'projectMgr',
($scope, projectMgr) ->

	class Controller

		constructor: ->
			$scope.project = projectMgr.project

	return new Controller()

]
