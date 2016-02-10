app = angular.module 'dugout', [
	'cfp.hotkeys'
	'gettext'
	'LocalStorageModule'
	'ngPrettyJson'
	'ngSanitize'
	'ngScrollbars'
	'sprintf'
	'toaster'
	'ui.bootstrap'
	'ui.router'
	'uiSwitch'
]

# Configure scrollbars
.config (ScrollBarsProvider) ->
	ScrollBarsProvider.defaults =
		mouseWheel:
			enable: true
			scrollAmount: 100
		axis: 'y'
		scrollInertia: 200
		autoHideScrollbar: true
		theme: 'minimal-dark'

.config [ 'localStorageServiceProvider', (localStorageServiceProvider) ->
	localStorageServiceProvider
		.setPrefix 'dugout'
		.setStorageType 'localStorage'
]

# Translation
.run ['gettext', 'gettextCatalog', (gettext, gettextCatalog) ->
	gettextCatalog.debug = false
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
.run [ '$rootScope', 'toaster', 'globalConfMgr', 'filesMgr', 'dockerUtil', 'projectMgr',
($rootScope, toaster, globalConfMgr, filesMgr, dockerUtil, projectMgr) ->
	globalConfMgr.load().then ->
		$rootScope.globalConfMgr = globalConfMgr
		dockerUtil.init()
		dockerUtil.docker.ping (error) ->
			if error
				toaster.pop
					type: 'error'
					title: gettextCatalog.getString gettext('Error')
					body: "#{gettextCatalog.getString gettext('Could not contact docker')}: #{error}"
		recentFiles = filesMgr.loadRecentFiles()
		if recentFiles.length
			filesMgr.loadConfigurationFile recentFiles[0]
			.then (data) ->
				projectMgr.init data
			, (error) ->
				toaster.pop
					type: 'error'
					title: gettextCatalog.getString gettext('Error')
					body: gettextCatalog.getString gettext('The configuration file could not be loaded.')
	, (error) ->
		console.dir error
]

# .run ->
# 	chokidar = require 'chokidar'
# 	watcher = chokidar.watch '.',
# 		ignored: /[\/\\]\./
# 	watcher.on 'all', (event, path) ->
# 		if location.reload and event == "change"
# 			location.reload()
