app
.controller 'containerImageCtrl',
['$scope', '$state', 'ngDialog', 'container',
($scope, $state, ngDialog, container) ->

	class Controller

		constructor: ->
			$scope.container = container

		pullImage: ->
			dialog = ngDialog.open
				template: 'pullDialog.html'
				className: 'ngdialog-theme-default'
				scope: $scope
			$scope.pullImageLog = []
			$scope.container.pullImage().then ->
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
