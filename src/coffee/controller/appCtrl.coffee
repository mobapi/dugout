app
.controller 'appCtrl',
['$scope', '$q', 'appGuiMgr', 'projectsMgr',
($scope, $q, appGuiMgr, projectsMgr) ->

	class Controller

		constructor: ->
			$scope.ctrl = @
			$scope.$watch 'configurationFilePath', (filePath) =>
				return if not filePath
				@loadFileContent(filePath).then (content) ->
					try
						data = JSON.parse content
					catch e
						alert gettextCatalog.getString(gettext("This file is not a valid json file !"))
					return if not data
					projectsMgr.init data
					projectsMgr.save()

		closeApp: ->
			appGuiMgr.closeApp()

		minimizeApp: ->
			appGuiMgr.minimizeApp()

		maximizeApp: ->
			appGuiMgr.maximizeApp()

		loadFileContent: (file) ->
			d = $q.defer()
			fs = require('fs');
			fs.readFile file, 'utf8', (error, content) ->
				return d.reject error if error
				return d.resolve content
			return d.promise

	return new Controller()

]
