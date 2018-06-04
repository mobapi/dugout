app
.controller 'navbarCtrl',
['$scope', '$state', '$q', 'toaster', 'appGuiMgr', '$uibModal', '$transitions', 'projectMgr',
($scope, $state, $q, toaster, appGuiMgr, $uibModal, $transitions, projectMgr) ->

	class Controller

		constructor: ->
			$('#side-menu').metisMenu()
			$scope.project = projectMgr.project
			$scope.footerSentence = sprintf(gettextCatalog.getString(gettext('Made with %(love)s in French Guiana by')),
				love: '<i class="fa fa-heart"></i>'
			)
			$transitions.onSuccess {}, (transition) =>
				@setActiveState()
			@setActiveState()

		setActiveState: ->
			delete $scope.activeState
			projectMgr.getContainer($state.params.name).then (container) ->
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

		pullImage: (container) ->
			modalInstance = $uibModal.open
				controller: 'pullDialogCtrl as ctrl'
				templateUrl: 'pullDialog.html'
				backdrop: 'static'
				size: 'lg'
				resolve:
					containers: -> [ container ]
			modalInstance.result.then ->
				container.checkContainerStatus()
			.catch ->
				console.log 'cancelled'

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
					.catch (error) ->
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
			container.stop()

		stopAll: ->
			projectMgr.stop()

	return new Controller()

]
