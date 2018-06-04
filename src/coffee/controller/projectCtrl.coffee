app
.controller 'projectCtrl',
['$scope', '$uibModal', 'projectMgr',
($scope, $uibModal, projectMgr) ->

	class Controller

		constructor: ->
			$scope.project = projectMgr.project

		pullImage: (container) ->
			modalInstance = $uibModal.open
				controller: 'pullDialogCtrl as ctrl'
				templateUrl: 'pullDialog.html'
				backdrop: 'static'
				size: 'lg'
				resolve:
					containers: -> [ container ]

	return new Controller()

]
