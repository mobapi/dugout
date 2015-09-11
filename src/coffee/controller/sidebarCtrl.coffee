app
.controller 'sidebarCtrl',
['$scope', 'projectsMgr',
($scope, projectsMgr) ->

	class Controller

		constructor: ->
			$('#side-menu').metisMenu()
			$scope.projects = projectsMgr.projects
			$scope.footerSentence = sprintf(gettextCatalog.getString(gettext('Made with %(love)s in French Guiana by')),
				love: '<i class="fa fa-heart"></i>'
			)

		startAll: ->
			projectsMgr.startAll()

		stopAll: ->
			projectsMgr.stopAll()

	return new Controller()

]
