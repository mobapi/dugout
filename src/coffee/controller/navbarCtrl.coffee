app
.controller 'navbarCtrl',
['$scope', '$state', '$q', 'appGuiMgr', 'projectMgr', 'containersMgr', 'dockerUtil',
($scope, $state, $q, appGuiMgr, projectMgr, containersMgr, dockerUtil) ->

	class Controller

		constructor: ->
			$('#side-menu').metisMenu()
			$scope.project = projectMgr.project
			$scope.footerSentence = sprintf(gettextCatalog.getString(gettext('Made with %(love)s in French Guiana by')),
				love: '<i class="fa fa-heart"></i>'
			)
			$scope.$root.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
				delete $scope.activeState
				$scope.activeContainer = $scope.project.containers[$state.params.id]
				if not $scope.activeContainer
					$scope.activeState = $state.current.name

		openPopupMenu: (event) ->
			appGuiMgr.openPopupMenu event.clientX, event.clientY

		closeApp: ->
			appGuiMgr.closeApp()

		minimizeApp: ->
			appGuiMgr.minimizeApp()

		maximizeApp: ->
			appGuiMgr.maximizeApp()

		start: (container) ->
			containersMgr.start(container).then null, (errors) ->
				notFoundErrors = _.filter errors, (item) ->
					return item.error.statusCode == 404
				if notFoundErrors.length
					console.dir notFoundErrors
					for error in notFoundErrors
						dockerUtil.pullImage container.iamge.name

		stop: (container) ->
			containersMgr.stop container

		stopAll: ->
			containersMgr.stopAll()

	return new Controller()

]
