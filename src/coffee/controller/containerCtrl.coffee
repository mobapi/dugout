app
.controller 'containerCtrl',
['$scope', '$state', 'container',
($scope, $state, container) ->

	class Controller

		constructor: ->
			$scope.container = container
			$scope.tabs = [{
				uri: 'logs'
				label: gettextCatalog.getString gettext('Logs')
				iconClass: 'stream stream-window-list'
				uiSref: "container.logs"
			}, {
				uri: 'container'
				label: gettextCatalog.getString gettext('Container')
				iconClass: 'stream stream-box'
				uiSref: "container.container"
			}, {
				uri: 'image'
				label: gettextCatalog.getString gettext('Image')
				iconClass: 'fa fa-clone'
				uiSref: "container.image"
			}, {
				uri: 'configuration'
				label: gettextCatalog.getString gettext('Configuration')
				iconClass: 'stream stream-cog'
				uiSref: "container.configuration"
			}]
			sp = $state.current.name.split '.'
			stateLastPart = sp[sp.length-1]
			$scope.selectedTab = _.find $scope.tabs,
				uri: stateLastPart
			$scope.setSelectedTab = (tab) ->
				$scope.selectedTab = tab
				$state.go tab.uiSref,
					id: $scope.container.id
			$scope.tabClass = (tab) ->
				if $scope.selectedTab == tab
					return "active"
				else
					return ""

	return new Controller()

]
