app
.controller 'projectCtrl',
['$scope', '$state', 'project',
($scope, $state, project) ->

	class Controller

		constructor: ->
			$scope.project = project
			$scope.tabs = [{
				uri: 'logs'
				label: gettextCatalog.getString gettext('Logs')
				iconClass: 'stream stream-window-list'
				uiSref: "project.logs"
			}, {
				uri: 'container'
				label: gettextCatalog.getString gettext('Container')
				iconClass: 'stream stream-box'
				uiSref: "project.container"
			}, {
				uri: 'image'
				label: gettextCatalog.getString gettext('Image')
				iconClass: 'fa fa-clone'
				uiSref: "project.image"
			}, {
				uri: 'configuration'
				label: gettextCatalog.getString gettext('Configuration')
				iconClass: 'stream stream-cog'
				uiSref: "project.configuration"
			}]
			sp = $state.current.name.split '.'
			stateLastPart = sp[sp.length-1]
			$scope.selectedTab = _.find $scope.tabs,
				uri: stateLastPart
			$scope.setSelectedTab = (tab) ->
				$scope.selectedTab = tab
				$state.go tab.uiSref,
					id: $scope.project.id
			$scope.tabClass = (tab) ->
				if $scope.selectedTab == tab
					return "active"
				else
					return ""

	return new Controller()

]
