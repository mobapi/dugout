app
.controller 'projectCtrl',
['$scope', '$state', 'project',
($scope, $state, project) ->

	class Controller

		constructor: ->
			$scope.project = project
			console.dir $state
			$scope.tabs = [{
				uri: 'logs'
				label: gettextCatalog.getString gettext('Log')
				iconClass: 'fa fa-th-list'
				uiSref: "project.logs"
			}, {
				uri: 'container'
				label: gettextCatalog.getString gettext('Container')
				iconClass: 'fa fa-align-justify fa-rotate-90'
				uiSref: "project.container"
			}, {
				uri: 'image'
				label: gettextCatalog.getString gettext('Image')
				iconClass: 'fa fa-clone'
				uiSref: "project.image"
			}, {
				uri: 'configuration'
				label: gettextCatalog.getString gettext('Configuration')
				iconClass: 'fa fa-gear'
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
