app
.controller 'pullDialogCtrl',
['$scope', 'toaster', '$uibModal', '$uibModalInstance', 'globalConfMgr', 'containers',
($scope, toaster, $uibModal, $uibModalInstance, globalConfMgr, containers) ->

	class Controller

		constructor: ->
			globalConfMgr.conf.credentials = {} if not globalConfMgr.conf.credentials
			@pullImages()

		pullImages: (credentials) ->
			containers = _.uniqBy containers, 'image'
			tasks = []
			for container in containers
				((container) =>
					if not credentials
						repositoryUrl = container.image.substring 0, container.image.indexOf('/')
						credentials = globalConfMgr.conf.credentials[repositoryUrl]
					$scope.image = container.image
					$scope.layers = {}
					tasks.push (callback) =>
						$scope.pullImageLog = []
						container.pullImage(credentials).then ->
							if credentials.remember
								repositoryUrl = container.image.substring 0, container.image.indexOf('/')
								globalConfMgr.conf.credentials[repositoryUrl] = credentials
								globalConfMgr.save()
							callback null, container
						, (error) ->
							callback error
						, (data) =>
							if data.progressDetail?.current
								data.progressDetail.percent = parseInt(data.progressDetail.current * 100.0 / data.progressDetail.total)
							$scope.layers[data.id] = data
				)(container)
			async.series tasks, (error, result) =>
				if error
					console.error error
					if /(authentication is required)|(unauthorized)/i.test error
						@login()
					else
						toaster.pop
							type: 'error'
							title: gettextCatalog.getString gettext('Error')
							body: "Unable to pull image: #{error}"
					return
				$uibModalInstance.close()

		login: ->
			loginInstance = $uibModal.open
				controller: 'loginDialogCtrl as ctrl'
				templateUrl: 'loginDialog.html'
				backdrop: 'static'

			loginInstance.result.then (credentials) =>
				@pullImages credentials
			, ->
				$uibModalInstance.dismiss()

		cancel: ->
			$uibModalInstance.dismiss()

	return new Controller()

]
