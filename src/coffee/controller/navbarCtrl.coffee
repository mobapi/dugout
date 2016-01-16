app
.controller 'navbarCtrl',
['$scope', '$state', '$q', 'appGuiMgr', '$uibModal', 'projectMgr', 'containersMgr',
($scope, $state, $q, appGuiMgr, $uibModal, projectMgr, containersMgr) ->

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
			containersMgr.start(container).then null, (errors) =>
				# Missing image handling
				notFoundErrors = _.filter errors, (item) ->
					return item.error.statusCode == 404
				if notFoundErrors.length
					images = _.map notFoundErrors, (item) ->
						return item.container.image

					modalInstance = $uibModal.open
						controller: 'pullDialogCtrl as ctrl'
						templateUrl: 'pullDialog.html'
						backdrop: 'static'
						size: 'lg'
						resolve:
							images: -> images

					modalInstance.result.then =>
						@start container
					, (error) ->
						console.dir error

		stop: (container) ->
			containersMgr.stop container

		stopAll: ->
			containersMgr.stopAll()

	return new Controller()

]
