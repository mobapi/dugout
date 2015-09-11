app
.controller 'configurationCtrl',
['$scope', '$state', 'toaster',
($scope, $state, toaster) ->

	class Controller

		constructor: ->
			$scope.globalConfMgr = $scope.$root.globalConfMgr
			$scope.conf = $scope.$root.globalConfMgr.conf
			$scope.languages = [{
				id: 'en'
				name: gettextCatalog.getString gettext('English')
			}, {
				id: 'fr'
				name: gettextCatalog.getString gettext('French')
			}]
			$scope.$watch 'conf', (newVal, oldVal) =>
				$scope.isConfigurationValid = $scope.globalConfMgr.isConfigurationValid()
				if newVal and newVal != oldVal
					@save()
			, true

		selectFile: (index) ->
			$("#file_#{index}").trigger 'click'

		detectCmd: (cmd) ->
			$scope.globalConfMgr.detectCmd(cmd).then (path) =>
				$scope.globalConfMgr.conf.commands[cmd] = path

		save: ->
			$scope.globalConfMgr.setLanguage $scope.conf.language
			$scope.globalConfMgr.save().then null, (error) ->
				toaster.pop
					type: 'error'
					title: gettextCatalog.getString gettext('Error')
					body: gettextCatalog.getString gettext('The configuration could not be saved.')

	return new Controller()

]
