app
.controller 'configurationCtrl',
['$scope', '$state', 'toaster', 'globalConfMgr',
($scope, $state, toaster, globalConfMgr) ->

	class Controller

		constructor: ->
			$scope.globalConfMgr = $scope.$root.globalConfMgr
			$scope.conf = $scope.$root.globalConfMgr.conf
			$scope.platform = window.process.platform
			if $scope.platform != 'linux' and not $scope.conf.docker.connectionType
				$scope.conf.docker.connectionType = 'tcpip'
			$scope.languages = [{
				id: 'en'
				name: 'English'
			}, {
				id: 'fr'
				name: 'Français'
			}]
			$scope.$watch 'conf', (newVal, oldVal) =>
				$scope.isConfigurationValid = $scope.globalConfMgr.isConfigurationValid()
				if newVal and newVal != oldVal
					@save()
			, true

		deleteCredentials: (key) ->
			delete globalConfMgr.conf.credentials[key]
			globalConfMgr.save()

		save: ->
			$scope.globalConfMgr.setLanguage $scope.conf.language
			$scope.globalConfMgr.save().then null, (error) ->
				toaster.pop
					type: 'error'
					title: gettextCatalog.getString gettext('Error')
					body: gettextCatalog.getString gettext('The configuration could not be saved.')

	return new Controller()

]
