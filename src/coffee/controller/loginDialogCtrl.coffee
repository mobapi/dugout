app
.controller 'loginDialogCtrl',
['$scope', '$uibModalInstance', 'dockerUtil',
($scope, $uibModalInstance, dockerUtil) ->

	class Controller

		login: ->
			$uibModalInstance.close $scope.credentials


	return new Controller()

]
