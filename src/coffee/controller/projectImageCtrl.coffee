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
			$scope.pullImageLog = []
			$scope.project.pullImage().then ->
				# dialog.close()
				$scope.pullImageLog += "\n\nUpdate done."
			, (error) ->
				console.error error
			, (data) ->
				data._id = Math.round((new Date()).getTime() * Math.random() * 10000)
				console.dir data
				$scope.pullImageLog.push data

	return new Controller()

]
