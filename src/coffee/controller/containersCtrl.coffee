app
.controller 'containersCtrl',
['$scope', '$state', 'containersMgr',
($scope, $state, containersMgr) ->

	class Controller

		constructor: ->
			$scope.containers = containersMgr.containers

	return new Controller()

]
