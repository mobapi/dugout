app
.controller 'projectImageCtrl',
['$scope', '$state', 'ngDialog', 'project',
($scope, $state, ngDialog, project) ->

	class Controller

		constructor: ->
			$scope.project = project

		pullImage: ->
			dialog = ngDialog.open
				template: 'pullDialog.html'
				className: 'ngdialog-theme-default'
				scope: $scope
			$scope.project.pullImage().then ->
				# dialog.close()
				$scope.pullImageLog += "\n\nUpdate done."
			, (error) ->
				console.error error
			, (data) ->
				$scope.pullImageLog = "" if not $scope.pullImageLog
				$scope.pullImageLog += data

	return new Controller()

]
