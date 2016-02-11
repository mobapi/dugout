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
			$scope.$root.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) =>
				@setActiveState()
			@setActiveState()

			$scope.$watch "project.containers", (containers) ->
				return if not containers
				for id, container of containers
					((container) ->
						state = container.runtime.infos.container.infos?.State
						container.runtime.canStart = !state or (not state.Starting and not state.Stopping and not state.Running and not state.Error)
						# container.runtime.canStart = !state or (not state.Starting and not state.Stopping and not state.Running and not state.Error and state.Status != 'exited')
						container.runtime.canStop = state && ((state.Running and not state.Stopping) or state.Error)
						# container.runtime.canStop = state && ((state.Running and not state.Stopping) or state.Error or state.Status == 'exited')
						# (container.runtime.infos.container.infos.State.Starting || container.runtime.infos.container.infos.State.Stopping) && container.runtime.infos.container.infos.State.Status != 'exited'
					)(container)
			, true

		setActiveState: ->
			delete $scope.activeState
			projectMgr.getContainer($state.params.id).then (container) ->
				$scope.activeContainer = container
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
					# images = _.map notFoundErrors, (item) ->
					# 	return item.container.image
					containers = _.map notFoundErrors, (item) -> item.container
					modalInstance = $uibModal.open
						controller: 'pullDialogCtrl as ctrl'
						templateUrl: 'pullDialog.html'
						backdrop: 'static'
						size: 'lg'
						resolve:
							containers: -> containers
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
							body: "#{gettextCatalog.getString(gettext('Unable to start container'))}: #{error.error}"

		stop: (container) ->
			projectMgr.stopContainer container

		stopAll: ->
			projectMgr.stop()

	return new Controller()

]
