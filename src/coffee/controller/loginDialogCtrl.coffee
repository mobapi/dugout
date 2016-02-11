app
.controller 'loginDialogCtrl',
['$scope', '$uibModalInstance',
($scope, $uibModalInstance) ->

	class Controller

		login: ->
			$uibModalInstance.close $scope.credentials


	return new Controller()

]
