app
.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

	# if none of the states are matched, use this as the fallback
	$urlRouterProvider.otherwise '/project'

	$stateProvider

	.state 'app',
		abstract: true
		url: ''
		views:
			'navbar':
				templateUrl: 'navbar.html'
				controller: 'navbarCtrl as ctrl'
			'main':
				template: '<div ui-view class="full-height"></div>'

	.state 'about',
		parent: 'app'
		url: '/about'
		templateUrl: 'about.html'
		controller: 'aboutCtrl as ctrl'

	.state 'project',
		parent: 'app'
		url: '/project'
		templateUrl: 'project.html'
		controller: 'projectCtrl as ctrl'

	.state 'container',
		abstract: true
		parent: 'app'
		url: '/containers/:name'
		templateUrl: 'container.html'
		controller: 'containerCtrl as ctrl'
		resolve:
			container: ['$stateParams', 'projectMgr', ($stateParams, projectMgr) ->
				return projectMgr.getContainer $stateParams.name
			]

	.state 'container.logs',
		url: '/logs'
		templateUrl: 'container_logs.html'
		controller: 'containerLogsCtrl as ctrl'

	.state 'container.container',
		url: '/container'
		templateUrl: 'container_container.html'
		controller: 'containerContainerCtrl as ctrl'

	.state 'container.image',
		url: '/image'
		templateUrl: 'container_image.html'
		controller: 'containerImageCtrl as ctrl'

	.state 'container.configuration',
		url: '/configuration'
		templateUrl: 'container_configuration.html'
		controller: 'containerConfigurationCtrl as ctrl'

	.state 'configuration',
		parent: 'app'
		url: '/configuration'
		templateUrl: 'configuration.html'
		controller: 'configurationCtrl as ctrl'

]
