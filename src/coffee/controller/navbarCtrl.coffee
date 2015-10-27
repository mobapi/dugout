app
.controller 'navbarCtrl',
['$scope', '$state', '$q', 'appGuiMgr', 'projectsMgr',
($scope, $state, $q, appGuiMgr, projectsMgr) ->

	class Controller

		constructor: ->
			$('#side-menu').metisMenu()
			$scope.projects = projectsMgr.projects
			$scope.footerSentence = sprintf(gettextCatalog.getString(gettext('Made with %(love)s in French Guiana by')),
				love: '<i class="fa fa-heart"></i>'
			)
			$scope.$root.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
				delete $scope.activeState
				$scope.activeProject = $scope.projects[$state.params.id]
				if not $scope.activeProject
					$scope.activeState = $state.current.name
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

		start: (project) ->
			projectsMgr.start project

		stop: (project) ->
			projectsMgr.stop project

		startAll: ->
			projectsMgr.startAll()

		stopAll: ->
			projectsMgr.stopAll()

	return new Controller()

]
