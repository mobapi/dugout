app
.controller 'navbarCtrl',
['$scope', '$state', '$q', 'appGuiMgr', 'projectMgr', 'containersMgr',
($scope, $state, $q, appGuiMgr, projectMgr, containersMgr) ->

	class Controller

		constructor: ->
			$('#side-menu').metisMenu()
			$scope.project = projectMgr.project
			# $scope.containers = containersMgr.containers
			$scope.footerSentence = sprintf(gettextCatalog.getString(gettext('Made with %(love)s in French Guiana by')),
				love: '<i class="fa fa-heart"></i>'
			)
			$scope.$root.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
				delete $scope.activeState
				$scope.activeContainer = $scope.project.containers[$state.params.id]
				if not $scope.activeContainer
					$scope.activeState = $state.current.name
			# $scope.$watch 'configurationFilePath', (filePath) =>
			# 	return if not filePath
			# 	containersMgr.loadConfigurationFile filePath

		openPopupMenu: (event) ->
			appGuiMgr.openPopupMenu event.clientX, event.clientY

		closeApp: ->
			appGuiMgr.closeApp()

		minimizeApp: ->
			appGuiMgr.minimizeApp()

		maximizeApp: ->
			appGuiMgr.maximizeApp()

		start: (container) ->
			containersMgr.start container

		stop: (container) ->
			containersMgr.stop container

		startAll: ->
			containersMgr.startAll()

		stopAll: ->
			containersMgr.stopAll()

	return new Controller()

]
