app
.controller 'pullDialogCtrl',
['$scope', '$uibModalInstance', 'dockerUtil', 'images',
($scope, $uibModalInstance, dockerUtil, images) ->

	class Controller

		constructor: ->
			console.dir images
			tasks = []
			for image in images
				((image) ->
					tasks.push (callback) ->
						$scope.pullImageLog = []
						dockerUtil.pullImage(image).then ->
							callback null, image
						, (error) ->
							callback error
						, (data) ->
							data._id = Math.round((new Date()).getTime() * Math.random() * 10000)
							console.dir data
							$scope.pullImageLog.push data
				)(image)
			async.series tasks, (error, result) ->
				if error
					console.dir error
					return
				$uibModalInstance.close()

		cancel: ->
			$uibModalInstance.dismiss()

	return new Controller()

]
