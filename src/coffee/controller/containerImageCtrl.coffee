app
.controller 'containerImageCtrl',
['$scope', '$state', '$uibModal', 'container',
($scope, $state, $uibModal, container) ->

	class Controller

		constructor: ->
			$scope.container = container

		pullImage: ->
			modalInstance = $uibModal.open
				controller: 'pullDialogCtrl as ctrl'
				templateUrl: 'pullDialog.html'
				backdrop: 'static'
				size: 'lg'
				resolve:
					containers: -> [ $scope.container ]

	return new Controller()

]
