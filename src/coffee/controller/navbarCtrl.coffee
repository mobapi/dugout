app
.controller 'navbarCtrl',
['$scope', '$state', '$q', 'toaster', 'appGuiMgr', '$uibModal', 'projectMgr',
($scope, $state, $q, toaster, appGuiMgr, $uibModal, projectMgr) ->

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
			projectMgr.startContainer(container).then null, (errors) =>
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
				# Other errors
				otherErrors = _.filter errors, (item) ->
					return item.error.statusCode != 404
				if otherErrors.length
					for error in otherErrors
						toaster.pop
							type: 'error'
							title: gettextCatalog.getString gettext('Error')
							body: "Unable to start container: #{error.error}"

		stop: (container) ->
			projectMgr.stopContainer container

		stopAll: ->
			projectMgr.stopAll()

	return new Controller()

]
