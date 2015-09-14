app
.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

	# if none of the states are matched, use this as the fallback
	$urlRouterProvider.otherwise '/projects'

	$stateProvider

	.state 'app',
		abstract: true
		url: ''
		views:
			'sidebar':
				templateUrl: 'sidebar.html'
				controller: 'sidebarCtrl as ctrl'
			'main':
				template: '<div ui-view class="full-height"></div>'

	.state 'about',
		parent: 'app'
		url: '/about'
		templateUrl: 'about.html'
		controller: 'aboutCtrl as ctrl'

	.state 'configuration',
		parent: 'app'
		url: '/configuration'
		templateUrl: 'configuration.html'
		controller: 'configurationCtrl as ctrl'

	.state 'projects',
		parent: 'app'
		url: '/projects'
		templateUrl: 'projects.html'
		controller: 'projectsCtrl as ctrl'

	.state 'project',
		abstract: true
		parent: 'app'
		url: '/projects/:id'
		templateUrl: 'project.html'
		controller: 'projectCtrl as ctrl'
		resolve:
			project: ['$stateParams', 'projectsMgr', ($stateParams, projectsMgr) ->
				return projectsMgr.get $stateParams.id
			]

	.state 'project.logs',
		url: '/logs'
		templateUrl: 'project_logs.html'
		controller: 'projectLogsCtrl as ctrl'

	.state 'project.container',
		url: '/container'
		templateUrl: 'project_container.html'
		controller: 'projectContainerCtrl as ctrl'

	.state 'project.image',
		url: '/image'
		templateUrl: 'project_image.html'
		controller: 'projectImageCtrl as ctrl'

	.state 'project.configuration',
		url: '/configuration'
		templateUrl: 'project_configuration.html'
		controller: 'projectConfigurationCtrl as ctrl'

]
