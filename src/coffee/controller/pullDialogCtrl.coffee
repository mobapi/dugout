app
.controller 'pullDialogCtrl',
['$scope', 'toaster', '$uibModal', '$uibModalInstance', 'dockerUtil', 'containers',
($scope, toaster, $uibModal, $uibModalInstance, dockerUtil, containers) ->

	class Controller

		constructor: ->
			@pullImages()

		pullImages: (credentials) ->
			containers = _.uniqBy containers, 'image'
			tasks = []
			for container in containers
				((container) =>
					$scope.image = container.image
					$scope.layers = {}
					tasks.push (callback) =>
						$scope.pullImageLog = []
						container.pullImage(credentials).then ->
							callback null, container
						, (error) ->
							callback error
						, (data) =>
							if data.progressDetail?.current
								data.progressDetail.percent = parseInt(data.progressDetail.current * 100.0 / data.progressDetail.total)
							$scope.layers[data.id] = data
						# dockerUtil.pullImage(image, credentials).then ->
						# 	callback null, image
						# , (error) ->
						# 	callback error
						# , (data) =>
						# 	if data.progressDetail?.current
						# 		data.progressDetail.percent = parseInt(data.progressDetail.current * 100.0 / data.progressDetail.total)
						# 	$scope.layers[data.id] = data
				)(container)
			async.series tasks, (error, result) =>
				if error
					console.error error
					if /^Authentication is required/.test error
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
				console.dir credentials
				@pullImages credentials
			, ->
				$uibModalInstance.dismiss()

		cancel: ->
			$uibModalInstance.dismiss()

	return new Controller()

]
