app
.controller 'containerConfigurationCtrl',
['$scope', '$state', 'projectMgr', 'container',
($scope, $state, projectMgr, container) ->

	class Controller

		constructor: ->
			$scope.container = container

			$scope.$watch 'container.variables', (newVal, oldVal) =>
				$scope.container.checkConfiguration()
				if newVal and newVal != oldVal
					@save()
				process = require 'process'
				if process.platform == 'win32'
					for k, variable of newVal
						if variable.type == 'directory' or variable.type == 'file'
							# newVal[k].value = newVal[k].value.replace /([A-Z])\:/, "//$1"
							newVal[k].value = newVal[k].value.replace /([A-Z])\:\\(.*)/, (match, p1, p2, offset, string) ->
								drive = p1.toLowerCase()
								return "//#{drive}/#{p2}"
							newVal[k].value = newVal[k].value.replace /\\/, "/"
			, true

		save: ->
			projectMgr.save()

	return new Controller()

]
