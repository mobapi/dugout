app
.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->

	# if none of the states are matched, use this as the fallback
	$urlRouterProvider.otherwise '/home'

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

	.state 'home',
		parent: 'app'
		url: '/home'
		templateUrl: 'home.html'
		controller: 'homeCtrl as ctrl'

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

	.state 'project',
		parent: 'app'
		url: '/projects/:id'
		templateUrl: 'project.html'
		controller: 'projectCtrl as ctrl'
		resolve:
			project: ['$stateParams', 'projectsMgr', ($stateParams, projectsMgr) ->
				return projectsMgr.get $stateParams.id
			]

]
