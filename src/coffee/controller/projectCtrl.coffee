app
.controller 'projectCtrl',
['$scope', '$state', 'toaster', 'ngDialog', 'projectsMgr', 'project',
($scope, $state, toaster, ngDialog, projectsMgr, project) ->

	class Controller

		constructor: ->
			$scope.project = project
			
			$scope.$watch 'project.variables', (newVal, oldVal) =>
				$scope.project.checkConfiguration()
				if newVal and newVal != oldVal
					@save()
			, true

			project.startContainerLog()

		save: ->
			projectsMgr.save()

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
