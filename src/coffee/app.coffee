app = angular.module 'dugout', [
	'cfp.hotkeys'
	'gettext'
	'LocalStorageModule'
	'luegg.directives' # scroll-glue
	'ngDialog'
	'ngPrettyJson'
	'ngSanitize'
	'perfect_scrollbar'
	'sprintf'
	'toaster'
	'ui.bootstrap'
	'ui.router'
]

.config [ 'localStorageServiceProvider', (localStorageServiceProvider) ->
	localStorageServiceProvider
		.setPrefix 'dugout'
		.setStorageType 'localStorage'
]

# Translation
.run ['gettext', 'gettextCatalog', (gettext, gettextCatalog) ->
	gettextCatalog.debug = true
	# gettext and gettextCatalog need to be global
	window.gettext = gettext
	window.gettextCatalog = gettextCatalog
	gettextCatalog.setCurrentLanguage 'en'
]

# Hotkeys
.run [ 'hotkeys', 'appGuiMgr', (hotkeys, appGuiMgr) ->
	openDebugger = ->
		appGuiMgr.showDevTools()
	keys = [ 'command+alt+i', 'command+alt+j', 'command+shift+i', 'command+shift+j', 'ctrl+shift+i', 'ctrl+shift+j', 'f12' ]
	for key in keys
		hotkeys.add
			combo: key
			callback: openDebugger
]

# App menu
.run [ 'appGuiMgr', (appGuiMgr) ->
	appGuiMgr.createMenu()
]

# Run run run !
.run [ '$rootScope', 'globalConfMgr', 'dockerUtil', 'projectsMgr',
($rootScope, globalConfMgr, dockerUtil, projectsMgr) ->
	globalConfMgr.load().then ->
		$rootScope.globalConfMgr = globalConfMgr
		dockerUtil.init()
		projectsMgr.init()
	, (error) ->
		console.dir error
]
